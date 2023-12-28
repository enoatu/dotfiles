package main

import (
	"bufio"
	"fmt"
	"os"
	"strings"
)

type SqlComment struct {
	BeforeColumnName string
	texts            []string
}

const INDENT = "  "

func main() {
	if len(os.Args) < 2 || os.Args[1] == "-h" || os.Args[1] == "--help" {
		fmt.Println("Usage: go run format_create_table.go create_table.sql")
		inputFile := `
---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS tag (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT            COMMENT 'ID',
  name VARCHAR(50) NOT NULL  COMMENT 'tag name',
  PRIMARY KEY (id),
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin COMMENT='simple tag';
---------------------------------------------------------------------------`
		inputFile = strings.Replace(inputFile, "\n", "", 1)
		fmt.Println("InputFile:")
		fmt.Println(inputFile)
		output := `
---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS tag (
  id                INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'ID',
  name              VARCHAR(50) NOT NULL                 COMMENT 'tag name',
  PRIMARY KEY (id),
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin COMMENT='simple tag';
---------------------------------------------------------------------------`
		output = strings.Replace(output, "\n", "", 1)
		fmt.Println("Output:")
		fmt.Println(output)
	}

	/*
		  コメントについては、以下について対応する
			行末の--、#
			行頭の--, #
			前後の文章に何もない/* から * /まで
	*/
	//	CREATE TABLE IF NOT EXISTS tag (
	//		id                INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'ID',
	//		name              VARCHAR(50) NOT NULL                 COMMENT 'tag name',
	//		-- taro: admin
	//		-- hanako: user
	//		non_smoking TEXT COMMENT '禁煙席'--(1:あり、0:なし),
	//		# comment
	//		/*test
	//		* infomation
	//		* test
	//		*/
	//		createdOn DATETIME COMMENT '作成日時',
	//		PRIMARY KEY (id),
	//	) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin COMMENT='simple tag';

	fileName := os.Args[1]

	// ファイルを開く
	file, err := os.Open(fileName)
	if err != nil {
		fmt.Println("Error opening file:", err)
		return
	}
	defer file.Close()

	scanner := bufio.NewScanner(file)
	if err := scanner.Err(); err != nil {
		fmt.Println("Error reading file:", err)
		return
	}
	result := formatCreateTable(scanner)
	fmt.Println(result)
}

func formatCreateTable(scanner *bufio.Scanner) string {
	columnLines := []string{}
	resultColumnLines := []string{}
	sqlComments := []SqlComment{}
	isStartColumn := false
	isStartMultiLineComment := false

	for scanner.Scan() {
		line := scanner.Text()
		// テーブル定義の行かどうかを判定する
		if strings.Contains(line, "CREATE TABLE") {
			isStartColumn = true
			resultColumnLines = append(resultColumnLines, line)
			continue
		}

		if !isStartColumn {
			resultColumnLines = append(resultColumnLines, line)
			continue
		}

		// SQLコメントは後で処理する
		if strings.Contains(line, "*/") {
			prevColumnLine := columnLines[len(columnLines)-1]
			safeColumnLineSplits := safeSplit(prevColumnLine, " ")
			sqlComments = addSqlComment(line, safeColumnLineSplits[0], sqlComments)
			isStartMultiLineComment = false
			continue
		}
		if strings.Contains(line, "/*") || isStartMultiLineComment {
			prevColumnLine := columnLines[len(columnLines)-1]
			safeColumnLineSplits := safeSplit(prevColumnLine, " ")
			sqlComments = addSqlComment(line, safeColumnLineSplits[0], sqlComments)
			isStartMultiLineComment = true
			continue
		}
		if len(line) > 8 && (strings.Contains(line[:8], "--") || strings.Contains(line[:8], "#")) {
			prevColumnLine := columnLines[len(columnLines)-1]
			safeColumnLineSplits := safeSplit(prevColumnLine, " ")
			sqlComments = addSqlComment(line, safeColumnLineSplits[0], sqlComments)
			continue
		}

		if isFinishedColumnLine(line) {
			isStartColumn = false
			formatedColumnLines := formatColumnLines(columnLines, sqlComments)
			resultColumnLines = append(resultColumnLines, formatedColumnLines...)
			resultColumnLines = append(resultColumnLines, line)
			columnLines = []string{}
			sqlComments = []SqlComment{}
			continue
		}

		columnLines = append(columnLines, line)
	}

	return strings.Join(resultColumnLines, "\n")
}

func formatColumnLines(columnLines []string, sqlComments []SqlComment) []string {
	// 半角スペースで分割して配列に格納する。ただし COMMENT以降は1つの要素として扱う
	columnLinesSplits := [][]string{}
	for _, columnLine := range columnLines {
		// 半角スペースで分割する
		splits := safeSplit(columnLine, " ")

		commentPos := 0
		for i, str := range splits {
			if str == "COMMENT" {
				commentPos = i
				break
			}
		}
		if commentPos == 0 {
			commentPos = len(splits) - 1
		}

		beforeComment := splits[:commentPos]
		afterComment := splits[commentPos:]
		result := append(beforeComment, strings.Join(afterComment, " "))
		// fmt.Println(strings.Join(result, "|"))
		columnLinesSplits = append(columnLinesSplits, result)
	}

	// 最大のカラム名の長さを取得し、その他を抽出する
	maxColumnNameLength := 0
	others := []string{}
	for _, columnLine := range columnLinesSplits {
		// カラム名の長さを取得する
		columnNameLength := len(columnLine[0])
		if maxColumnNameLength < columnNameLength {
			maxColumnNameLength = columnNameLength
		}
		// 型名からCOMMENTまでがその他
		other := ""
		for i := 2; i < len(columnLine); i++ {
			if strings.Contains(columnLine[i], "COMMENT") {
				break
			}
			other += columnLine[i]
			other += " "
		}
		others = append(others, other)
	}

	// カラム名+型を揃え、その一番長い長さを取得する
	resultColumnLines := []string{}
	maxColumnNameTypeLength := 0
	for _, columnLineSplits := range columnLinesSplits {
		// カラム名の長さを取得する
		columnNameLength := len(columnLineSplits[0])

		// カラム名の長さを揃える
		columnName := columnLineSplits[0]
		for i := 0; i < maxColumnNameLength-columnNameLength; i++ {
			columnName += " "
		}

		// カラム名の後ろに型を入れる
		columnNameType := columnName + " " + columnLineSplits[1]
		resultColumnLines = append(resultColumnLines, columnNameType)

		if maxColumnNameTypeLength < len(columnNameType) {
			maxColumnNameTypeLength = len(columnNameType)
		}
	}
	// fmt.Println(strings.Join(resultColumnLines, "\n"))

	// カラム名+型+その他を揃え、その一番長い長さを取得する
	maxColumnNameTypeOtherLength := 0
	for i, columnLine := range resultColumnLines {
		// カラム名+型の長さを取得する
		if false {
			// othersの頭を揃える
			columnNameTypeLength := len(columnLine)
			for j := 0; j < maxColumnNameTypeLength-columnNameTypeLength; j++ {
				columnLine += " "
			}
		}
		columnLine += " "
		columnLine += others[i]
		resultColumnLines[i] = columnLine

		if maxColumnNameTypeOtherLength < len(columnLine) {
			maxColumnNameTypeOtherLength = len(columnLine)
		}
	}
	// fmt.Println(strings.Join(resultColumnLines, "\n"))

	// カラム名+型+その他+COMMENTを揃える
	for i, columnLine := range resultColumnLines {
		// カラム名+型+その他の長さを取得する
		columnNameTypeOtherLength := len(columnLine)
		for j := 0; j < maxColumnNameTypeOtherLength-columnNameTypeOtherLength; j++ {
			columnLine += " "
		}
		// COMMENTを追加する
		for _, split := range columnLinesSplits[i] {
			if strings.Contains(split, "COMMENT") {
				columnLine += columnLinesSplits[i][len(columnLinesSplits[i])-1]
				break
			}
		}

		resultColumnLines[i] = INDENT + columnLine
	}
	// fmt.Println(strings.Join(resultColumnLines, "\n"))

	columnLineStrings := []string{}
	// SQLコメントを追加する
	for i, columnLine := range resultColumnLines {
		for _, sqlComment := range sqlComments {
			if sqlComment.BeforeColumnName == columnLinesSplits[i][0] {
				columnLine += "\n" + strings.Join(sqlComment.texts, "\n")
			}
		}
		columnLineStrings = append(columnLineStrings, columnLine)
	}

	return columnLineStrings
}

func isFinishedColumnLine(line string) bool {
	//  頭3文字内に)がある、またはCOMMENTがない場合はカラム定義が終わっていると判断する
	if len(line) > 3 && strings.Contains(line[:3], ")") {
		return true
	}

	splits := safeSplit(line, " ")
	for _, split := range splits {
		if strings.Contains(split, "INDEX") ||
			strings.Contains(split, "KEY") ||
			strings.Contains(split, "FULLTEXT") ||
			strings.Contains(split, "SPATIAL") ||
			strings.Contains(split, "CONSTRAINT") ||
			strings.Contains(split, "PRIMARY KEY") ||
			strings.Contains(split, "UNIQUE") ||
			strings.Contains(split, "FOREIGN KEY") ||
			strings.Contains(split, "CHECK") {
			return true
		}
	}
	return false
}

func safeSplit(str string, delimiter string) []string {
	// 半角スペースで分割する
	splits := strings.Split(str, delimiter)
	// 空文字は削除する
	emptySafeSplits := []string{}
	for _, s := range splits {
		if s != "" {
			emptySafeSplits = append(emptySafeSplits, s)
		}
	}
	return emptySafeSplits
}

func addSqlComment(line, columnName string, sqlComments []SqlComment) []SqlComment {
	isAdded := false
	for i, sqlComment := range sqlComments {
		if sqlComment.BeforeColumnName == columnName {
			sqlComment.texts = append(sqlComment.texts, line)
			sqlComments[i] = sqlComment
			isAdded = true
		}
	}
	if !isAdded {
		sqlComments = append(sqlComments, SqlComment{
			BeforeColumnName: columnName,
			texts:            []string{line},
		})
	}
	return sqlComments
}

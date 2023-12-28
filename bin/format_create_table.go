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
	rows := []string{}
	resultLines := []string{}
	sqlComments := []SqlComment{}
	lines := []string{}

	isStartColumn := false

	for scanner.Scan() {
		line := scanner.Text()
		lines = append(lines, line)
	}
	for _, line := range lines {
		// テーブル定義の行かどうかを判定する
		if strings.Contains(line, "CREATE TABLE") {
			isStartColumn = true
			resultLines = append(resultLines, line)
			continue
		}

		if !isStartColumn {
			resultLines = append(resultLines, line)
			continue
		}

		// SQLコメントは後で処理する
		if strings.Contains(line, "--") || strings.Contains(line, "#") {
			prevRow := rows[len(rows)-1]
			safeRowSplits := safeSplit(prevRow, " ")
			for i, sqlComment := range sqlComments {
				if sqlComment.BeforeColumnName == safeRowSplits[0] {
					sqlComment.texts = append(sqlComment.texts, line)
					sqlComments[i] = sqlComment
				}
			}
			continue
		}

		if isFinishedColumnLine(line) {
			isStartColumn = false
			formatedInnerRaw := formatInner(rows, sqlComments)
			formatedInner := []string{}
			for _, row := range formatedInnerRaw {
				resultLines = append(resultLines, row)
			}

			resultLines = append(resultLines, formatedInner...)
			resultLines = append(resultLines, line)
			rows = []string{}
			sqlComments = []SqlComment{}
			continue
		}

		rows = append(rows, line)
	}

	return strings.Join(resultLines, "\n")
}

func formatInner(rows []string, sqlComments []SqlComment) []string {
	// 半角スペースで分割して配列に格納する。ただし COMMENT以降は1つの要素として扱う
	rowsSplits := [][]string{}
	for _, row := range rows {
		// 半角スペースで分割する
		splits := safeSplit(row, " ")

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
		rowsSplits = append(rowsSplits, result)
	}

	// 最大のカラム名の長さを取得し、その他を抽出する
	maxColumnNameLength := 0
	others := []string{}
	for _, row := range rowsSplits {
		// カラム名の長さを取得する
		columnNameLength := len(row[0])
		if maxColumnNameLength < columnNameLength {
			maxColumnNameLength = columnNameLength
		}
		// 型名からCOMMENTまでがその他
		other := ""
		for i := 2; i < len(row); i++ {
			if strings.Contains(row[i], "COMMENT") {
				break
			}
			other += row[i]
			other += " "
		}
		others = append(others, other)
	}

	// カラム名+型を揃え、その一番長い長さを取得する
	resultRows := []string{}
	maxColumnNameTypeLength := 0
	for _, rowSplits := range rowsSplits {
		// カラム名の長さを取得する
		columnNameLength := len(rowSplits[0])

		// カラム名の長さを揃える
		columnName := rowSplits[0]
		for i := 0; i < maxColumnNameLength-columnNameLength; i++ {
			columnName += " "
		}

		// カラム名の後ろに型を入れる
		columnNameType := columnName + " " + rowSplits[1]
		resultRows = append(resultRows, columnNameType)

		if maxColumnNameTypeLength < len(columnNameType) {
			maxColumnNameTypeLength = len(columnNameType)
		}
	}
	// fmt.Println(strings.Join(resultRows, "\n"))

	// カラム名+型+その他を揃え、その一番長い長さを取得する
	maxColumnNameTypeOtherLength := 0
	for i, row := range resultRows {
		// カラム名+型の長さを取得する
		if false {
			// othersの頭を揃える
			columnNameTypeLength := len(row)
			for j := 0; j < maxColumnNameTypeLength-columnNameTypeLength; j++ {
				row += " "
			}
		}
		row += " "
		row += others[i]
		resultRows[i] = row

		if maxColumnNameTypeOtherLength < len(row) {
			maxColumnNameTypeOtherLength = len(row)
		}
	}
	// fmt.Println(strings.Join(resultRows, "\n"))

	// カラム名+型+その他+COMMENTを揃える
	for i, row := range resultRows {
		// カラム名+型+その他の長さを取得する
		columnNameTypeOtherLength := len(row)
		for j := 0; j < maxColumnNameTypeOtherLength-columnNameTypeOtherLength; j++ {
			row += " "
		}
		// COMMENTを追加する
		for _, split := range rowsSplits[i] {
			if strings.Contains(split, "COMMENT") {
				row += rowsSplits[i][len(rowsSplits[i])-1]
				break
			}
		}

		resultRows[i] = INDENT + row
	}
	// fmt.Println(strings.Join(resultRows, "\n"))

	rowStrings := []string{}
	// SQLコメントを追加する
	for i, row := range resultRows {
		for _, sqlComment := range sqlComments {
			if sqlComment.BeforeColumnName == rowsSplits[i][0] {
				row += "\n" + strings.Join(sqlComment.texts, "\n")
			}
		}
		rowStrings = append(rowStrings, row)
	}

	return rowStrings
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

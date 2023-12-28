// 以下のように、MySQLのテーブルで半角スペースを入れ、型とCOMMENT を1列に並べるように整形する
// 実行前
//
// CREATE TABLE IF NOT EXISTS tag (
//   id      INT UNSIGNED NOT NULL AUTO_INCREMENT            COMMENT 'ID',
//   site_id    INT UNSIGNED NOT NULL   COMMENT 'siteのID',
//   kind  TINYINT UNSIGNED NOT NULL DEFAULT 1    COMMENT '種別',
//   name    VARCHAR(50) NOT NULL    COMMENT 'タグ名',
//   created_on   DATETIME NOT NULL    COMMENT '作成日時',
//   modified_on  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '最終更新日時',
//   PRIMARY KEY (id),
//   UNIQUE KEY tag_unique01 (site_id,   kind,   name)
// ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin COMMENT='タグ';
//
// 実行後
//
// CREATE TABLE IF NOT EXISTS tag (
//   id                INT UNSIGNED NOT NULL AUTO_INCREMENT                                     COMMENT 'ID',
//   site_id           INT UNSIGNED NOT NULL                                                    COMMENT 'siteのID',
//   kind              TINYINT UNSIGNED NOT NULL DEFAULT 1                                      COMMENT '種別',
//   name              VARCHAR(50) NOT NULL                                                     COMMENT 'タグ名',
//   created_on        DATETIME NOT NULL                                                        COMMENT '作成日時',
//   modified_on       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '最終更新日時',
//   PRIMARY KEY (id),
//   UNIQUE KEY tag_unique01 (site_id, kind, name)
// ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin COMMENT='タグ';

package main

import (
	"bufio"
	"fmt"
	"os"
	"strings"
)

func main() {
	if len(os.Args) < 2 || os.Args[1] == "-h" || os.Args[1] == "--help" {
		fmt.Println("Usage: go run format_create_table.go create_table.sql")
        inputFile := `
---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS tag (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT            COMMENT 'ID',
  name VARCHAR(50) NOT NULL  COMMENT 'タグ名',
  PRIMARY KEY (id),
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin COMMENT='タグ';
---------------------------------------------------------------------------`
        inputFile = strings.Replace(inputFile, "\n", "", 1)
        fmt.Println("InputFile:")
        fmt.Println(inputFile)
        output := `
---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS tag (
  id                INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'ID',
  name              VARCHAR(50) NOT NULL                 COMMENT 'タグ名',
  PRIMARY KEY (id),
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin COMMENT='タグ';
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
    formatCreateTable(scanner)
}

func formatCreateTable(scanner *bufio.Scanner) {
	// ファイルを1行ずつ読み込む
	isRowStart := false
	rows := []string{}
	sqlCommentsPosition := []int{}
	for scanner.Scan() {
		line := scanner.Text()

	  // テーブル定義の行かどうかを判定する
	  // 括弧の中かつ、COMMENT が存在する

		if strings.Contains(line, "(") {
			isRowStart = true
			continue
		}

		if !isRowStart {
			continue
		}

		if strings.Contains(line, ")") {
			isRowStart = false
			continue
		}

		if strings.Contains(line, "COMMENT") {
			rows = append(rows, line)
		} else {
			// SQLコメントは無視する
			if strings.Contains(line, "--") {
				sqlCommentsPosition = append(sqlCommentsPosition, len(rows))
			}
		}
	}

	// 半角スペースで分割して配列に格納する。ただし COMMENT以降は1つの要素として扱う
	rowsSplited := [][]string{}
	for _, row := range rows {
		// 半角スペースで分割する
		rowSplited := strings.Split(row, " ")
		// 空文字は削除する
		emptySafeRowSplited := []string{}
		for _, str := range rowSplited {
			if str != "" {
				emptySafeRowSplited = append(emptySafeRowSplited, str)
			}
		}
		// fmt.Println(strings.Join(emptySafeRowSplited, "|"))

		commentPos := 0
		for i, str := range emptySafeRowSplited {
			if str == "COMMENT" {
				commentPos = i
				break
			}
		}

		beforeComment := emptySafeRowSplited[:commentPos]
		afterComment := emptySafeRowSplited[commentPos:]
		result := append(beforeComment, strings.Join(afterComment, " "))
		fmt.Println(strings.Join(result, "|"))
		rowsSplited = append(rowsSplited, result)
	}

	// カラム名 型名 その他 COMMENT SQLコメント という形式
	// 最大のカラム名の長さを取得
	// その他を抽出する
	maxColumnNameLength := 0
	others := []string{}
	for _, row := range rowsSplited {
		// カラム名の長さを取得する
		columnNameLength := len(row[0])
		if maxColumnNameLength < columnNameLength {
			maxColumnNameLength = columnNameLength
		}
		// 型名からCOMMENTまでがその他
		// その他を抽出する
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
	for _, rowSplited := range rowsSplited {
		// カラム名の長さを取得する
		columnNameLength := len(rowSplited[0])

		// カラム名の長さを揃える
		columnName := rowSplited[0]
		for i := 0; i < maxColumnNameLength-columnNameLength; i++ {
			columnName += " "
		}

		// カラム名の後ろに型を入れる
		columnNameType := columnName + " " + rowSplited[1]
		resultRows = append(resultRows, columnNameType)

		if maxColumnNameTypeLength < len(columnNameType) {
			maxColumnNameTypeLength = len(columnNameType)
		}
	}

	// カラム名+型+その他を揃え、その一番長い長さを取得する
	fmt.Println(strings.Join(resultRows, "\n"))

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
	fmt.Println(strings.Join(resultRows, "\n"))

	// カラム名+型+その他+COMMENTを揃える
	for i, row := range resultRows {
		// カラム名+型+その他の長さを取得する
		columnNameTypeOtherLength := len(row)
		for j := 0; j < maxColumnNameTypeOtherLength-columnNameTypeOtherLength; j++ {
			row += " "
		}
		// COMMENTを追加する
		row += rowsSplited[i][len(rowsSplited[i])-1]
		resultRows[i] = row
	}
	fmt.Println(strings.Join(resultRows, "\n"))
}


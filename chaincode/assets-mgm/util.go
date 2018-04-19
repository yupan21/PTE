package main

import (
	"strconv"
)

// 判断变量是否为初始零值
func isEmpty(arg interface{}) bool {
	switch v := arg.(type) {
	case int32:
		if v == 0 {
			return true
		} else {
			return false
		}
	case int64:
		if v == 0 {
			return true
		} else {
			return false
		}
	case float64:
		if v == 0.0 {
			return true
		} else {
			return false
		}
	case string:
		if v == "" {
			return true
		} else {
			return false
		}
	default:
		return true // 默认为空，不改变原值
	}
}

// 接口转换为string
func interfaceTostring(arg interface{}) string {
	switch v := arg.(type) {
	case int32:
		val := strconv.Itoa(int(v))
		return val
	case int64:
		val := strconv.Itoa(int(v))
		return val
	case float64:
		val := strconv.AppendFloat([]byte(""), v, 'f', 5, 32)
		return string(val)
	case string:
		return v
	default:
		return ""
	}
}

// 字符串首字母转小写
func strFirstToLower(str string) string {
	ans := ""
	for i, ch := range str {
		if i == 0 {
			if ch >= 65 && ch <= 90 {
				ans = ans + string(ch+32) // 首字母，大写转小写
			} else {
				ans = ans + string(ch)
			}
		} else {
			ans = ans + string(ch)
		}
	}

	return ans
}

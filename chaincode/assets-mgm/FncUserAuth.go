package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"reflect"
	"strconv"
	"strings"
	"time"

	"github.com/hyperledger/fabric/core/chaincode/shim"
	pb "github.com/hyperledger/fabric/protos/peer"
)

/**************************************************************************************/
// 融资用户授权结构体
type FncUserAuth struct {
	ObjectType string `json:"docType"`    // 类型
	Id         int64  `json:"id"`         // 主键
	CreateTime int64  `json:"createTime"` // 创建时间
	UpdateTime int64  `json:"updateTime"` // 更新时间
	CreateUser string `json:"createUser"` // 创建人
	UpdateUser string `json:"updateUser"` // 更新人
	ExpdId     string `json:"expdId"`     // 扩展ID
	DelInd     string `json:"delInd"`     // 删除标志
	Version    int32  `json:"version"`    // 版本号
	TenantId   string `json:"tenantId"`   // 租户ID

	FncUserAuthId string `json:"fncUserAuthId"` //融资用户授权编号
	AuthId        string `json:"authId"`        //授权编号，表征一次授权动作
	FncJrnlId     string `json:"fncJrnlId"`     //融资编号
	AuthedUserId  string `json:"authedUserId"`  //被授权用户编号
	AuthExpDt     int64  `json:"authExpDt"`     //授权到期日期

}

// 用于解析queryString
type QryStrFncUserAuth struct {
	Selector FncUserAuth `json:"selector"`
}

// 判断FncUserAuth变量是否为空
func isEmptyFncUserAuth(arg FncUserAuth) bool {
	value := reflect.ValueOf(arg)
	num := 0
	for i := 0; i < value.NumField(); i++ {
		if isEmpty(value.Field(i).Interface()) {
			num++
		}
	}

	if num == value.NumField() {
		return true
	} else {
		return false
	}
}

// FncUserAuth变量变为queryString
func tranfFncUserAuthToQryStr(arg FncUserAuth) string {
	queryString := "{\"selector\":{\"docType\":\"FncUserAuth\"" // 封装，头部

	value := reflect.ValueOf(arg)
	typ := reflect.TypeOf(arg)
	for i := 1; i < value.NumField(); i++ { // Field(0)跳过
		if !isEmpty(value.Field(i).Interface()) {
			keyname := typ.Field(i).Name
			keystring := strFirstToLower(keyname)
			valuestring := interfaceTostring(value.Field(i).Interface())
			partstring := fmt.Sprintf(",\"%v\":\"%v\"", keystring, valuestring)
			queryString = queryString + partstring
		}
	}
	queryString = queryString + "}}" // 封装，尾部

	return queryString
}

/**************************************************************************************/
// 保存或更新fncUserAuth
func saveOrUpdateFncUserAuth(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	var err error
	fmt.Println("- start saveOrUpdate fncUserAuth")

	if len(args) < 1 {
		return shim.Error("Incorrect number of arguments. Expecting 1")
	}

	fncUserAuth := args[0]
	//	fmt.Println("- the received fncUserAuth args is :",fncUserAuth)
	fncUserAuth1 := FncUserAuth{}
	err = json.Unmarshal([]byte(fncUserAuth), &fncUserAuth1)
	if err != nil {
		return shim.Error(err.Error())
	}

	if fncUserAuth1.FncJrnlId == "" {
		return shim.Error("FncJrnlId can't be null")
	} else if fncUserAuth1.AuthedUserId == "" {
		return shim.Error("AuthedUserId can't be null")
	} else if fncUserAuth1.FncUserAuthId == "" {
		return shim.Error("FncUserAuthId can't be null")
	} else {
		fncUserAuthFromState, err := stub.GetState("FncUserAuth" + fncUserAuth1.FncUserAuthId)
		if err != nil {
			return shim.Error("Failed to get fncUserAuth:" + err.Error())
		} else if fncUserAuthFromState == nil {
			fncUserAuth1.ObjectType = "FncUserAuth"
			fncUserAuth1.DelInd = "0" // 删除标志，初始值为0
			fncUserAuthToState, err := json.Marshal(fncUserAuth1)
			err = stub.PutState("FncUserAuth"+fncUserAuth1.FncUserAuthId, fncUserAuthToState)
			if err != nil {
				return shim.Error(err.Error())
			}

			timestamp := time.Now().Format("2006-01-02 15:04:05")
			fmt.Printf("- save successfully ! %v \n", timestamp)

			return shim.Success(nil)
		} else {
			fncUserAuth2 := FncUserAuth{}
			err = json.Unmarshal([]byte(fncUserAuthFromState), &fncUserAuth2)
			value1 := reflect.ValueOf(&fncUserAuth1).Elem()
			value2 := reflect.ValueOf(&fncUserAuth2).Elem()
			for i := 0; i < value1.NumField(); i++ {
				if !isEmpty(value1.Field(i).Interface()) {
					value2.Field(i).Set(value1.Field(i))
				}
			}
			fncUserAuthToState, err := json.Marshal(fncUserAuth2)
			err = stub.PutState("FncUserAuth"+fncUserAuth1.FncUserAuthId, fncUserAuthToState)
			if err != nil {
				return shim.Error(err.Error())
			}

			timestamp := time.Now().Format("2006-01-02 15:04:05")
			fmt.Printf("- update successfully ! %v \n", timestamp)
			//			fmt.Printf("- the key of record is : FncUserAuth%v \n",fncUserAuth1.FncUserAuthId)
			//			fmt.Printf("- the value of record is ： %v \n",string(fncUserAuthToState))

		}
	}
	return shim.Success(nil)
}

// 保存或更新fncUserAuth列表
func saveOrUpdateFncUserAuthList(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	var err error
	fmt.Println("- start saveOrUpdate fncUserAuthList")

	if len(args) < 1 {
		return shim.Error("Incorrect number of arguments. Expecting 1")
	}

	fncUserAuthList := args[0]
	//	fmt.Println("- the received fncUserAuth args is :",fncUserAuth)
	fncUserAuth1List := []FncUserAuth{}
	err = json.Unmarshal([]byte(fncUserAuthList), &fncUserAuth1List)
	if err != nil {
		return shim.Error(err.Error())
	}

	for _, fncUserAuth1 := range fncUserAuth1List {
		if fncUserAuth1.FncJrnlId == "" {
			return shim.Error("FncJrnlId can't be null")
		} else if fncUserAuth1.AuthedUserId == "" {
			return shim.Error("AuthedUserId can't be null")
		} else if fncUserAuth1.FncUserAuthId == "" {
			return shim.Error("FncUserAuthId can't be null")
		} else {
			fncUserAuthFromState, err := stub.GetState("FncUserAuth" + fncUserAuth1.FncUserAuthId)
			if err != nil {
				return shim.Error("Failed to get fncUserAuth:" + err.Error())
			} else if fncUserAuthFromState == nil {
				fncUserAuth1.ObjectType = "FncUserAuth"
				fncUserAuth1.DelInd = "0" // 删除标志，初始值为0
				fncUserAuthToState, err := json.Marshal(fncUserAuth1)
				err = stub.PutState("FncUserAuth"+fncUserAuth1.FncUserAuthId, fncUserAuthToState)
				if err != nil {
					return shim.Error(err.Error())
				}

				timestamp := time.Now().Format("2006-01-02 15:04:05")
				fmt.Printf("- save successfully ! %v \n", timestamp)

				//return shim.Success(nil)
			} else {
				fncUserAuth2 := FncUserAuth{}
				err = json.Unmarshal([]byte(fncUserAuthFromState), &fncUserAuth2)
				value1 := reflect.ValueOf(&fncUserAuth1).Elem()
				value2 := reflect.ValueOf(&fncUserAuth2).Elem()
				for i := 0; i < value1.NumField(); i++ {
					if !isEmpty(value1.Field(i).Interface()) {
						value2.Field(i).Set(value1.Field(i))
					}
				}
				fncUserAuthToState, err := json.Marshal(fncUserAuth2)
				err = stub.PutState("FncUserAuth"+fncUserAuth1.FncUserAuthId, fncUserAuthToState)
				if err != nil {
					return shim.Error(err.Error())
				}

				timestamp := time.Now().Format("2006-01-02 15:04:05")
				fmt.Printf("- update successfully ! %v \n", timestamp)
				//			fmt.Printf("- the key of record is : FncUserAuth%v \n",fncUserAuth1.FncUserAuthId)
				//			fmt.Printf("- the value of record is ： %v \n",string(fncUserAuthToState))

			}
		}
	}

	return shim.Success(nil)
}

// Deletes an entity from state
func deleteFncUserAuth(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	if len(args) != 1 {
		return shim.Error("Incorrect number of arguments. Expecting fncUserAuthId of the fncUserAuth to delete")
	}

	fncUserAuthId := strings.ToLower(args[0])

	// Delete the key from the state in ledger
	err := stub.DelState("FncUserAuth" + fncUserAuthId)
	if err != nil {
		return shim.Error("Failed to delete state for " + fncUserAuthId)
	}

	return shim.Success(nil)
}

// 通过fncUserAuthId查询fncUserAuth
func queryFncUserAuthByFncUserAuthId(stub shim.ChaincodeStubInterface, args []string) pb.Response {

	var err error
	var fncUserAuthId, jsonResp string

	fmt.Println("- start query fncUserAuth by fncUserAuthId")

	if len(args) != 1 {
		return shim.Error("Incorrect number of arguments. Expecting fncUserAuthId of the fncUserAuth to query")
	}

	fncUserAuthId = strings.ToLower(args[0])

	fncUserAuthFromState, err := stub.GetState("FncUserAuth" + fncUserAuthId)

	if err != nil {
		jsonResp = "{\"Error\":\"Failed to get state for " + fncUserAuthId + "\"}"
		return shim.Error(jsonResp)
	} else if fncUserAuthFromState == nil {
		jsonResp = "{\"Error\":\"fncUserAuth does not exist: " + fncUserAuthId + "\"}"
		return shim.Error(jsonResp)
	}

	var buffer bytes.Buffer // 缓存，用来保存查询结果
	buffer.WriteString("{\"Key\":")
	buffer.WriteString("\"FncUserAuth")
	buffer.WriteString(fncUserAuthId)
	buffer.WriteString("\"")
	buffer.WriteString(", \"Value\":")
	buffer.WriteString(string(fncUserAuthFromState))
	buffer.WriteString("}")

	timestamp := time.Now().Format("2006-01-02 15:04:05")
	fmt.Printf("- query by fncUserAuthId successfully ! %v \n", timestamp)
	//	fmt.Printf("- the query result is : \n")
	//	fmt.Printf("  %v \n",buffer.String())

	return shim.Success(buffer.Bytes())
}

// 通过querystring查询fncUserAuth(复杂查询)
func queryFncUserAuthByQryStr(stub shim.ChaincodeStubInterface, args []string) pb.Response {

	var err error
	var queryString string

	//	fmt.Println("- start query gldAccvalRltv by queryString, the queryString is : \n %v \n",queryString )
	fmt.Println("- start query fncUserAuth by queryString")

	if len(args) != 1 {
		return shim.Error("Incorrect number of arguments. Expecting querystring of the fncUserAuth to query")
	}
	queryString = args[0]

	if queryString == "" { // 判定querystring是否为空
		return shim.Error("The queryString can not be null ")
	}
	qryStrFncUserAuth := QryStrFncUserAuth{}
	err = json.Unmarshal([]byte(queryString), &qryStrFncUserAuth)
	if err != nil {
		return shim.Error(err.Error())
	}
	if isEmptyFncUserAuth(qryStrFncUserAuth.Selector) { // 判断queryString中有没有查询条件
		return shim.Error("The selector of queryString can not be null ")
	}

	querystring := tranfFncUserAuthToQryStr(qryStrFncUserAuth.Selector)

	resultsIterator, err := stub.GetQueryResult(querystring) // 返回迭代器，querystring格式：{"selector":{"docType":"FncUserAuth","CreateUser":"jzk",...}}
	if err != nil {
		return shim.Error(err.Error())
	}
	defer resultsIterator.Close()

	if !resultsIterator.HasNext() {
		timestamp := time.Now().Format("2006-01-02 15:04:05")
		fmt.Printf("- can not find fncUserAuth by querystring ! %v \n", timestamp)
		return shim.Success([]byte("can not find fncUserAuth by querystring"))
	}
	var buffer bytes.Buffer
	buffer.WriteString("[") // 封装成对象数组json串格式
	bArrayMemberAlreadyWritten := false
	for resultsIterator.HasNext() {
		queryResponse, err := resultsIterator.Next()
		if err != nil {
			return shim.Error(err.Error())
		}
		if bArrayMemberAlreadyWritten == true {
			buffer.WriteString(",")
		}
		buffer.WriteString("{\"Key\":")
		buffer.WriteString("\"")
		buffer.WriteString(queryResponse.Key)
		buffer.WriteString("\"")

		buffer.WriteString(", \"Value\":")
		buffer.WriteString(string(queryResponse.Value))
		buffer.WriteString("}")
		bArrayMemberAlreadyWritten = true
	}
	buffer.WriteString("]")

	timestamp := time.Now().Format("2006-01-02 15:04:05")
	fmt.Printf("- query by queryString successfully ! %v \n", timestamp)
	//	fmt.Printf("- the query result is : \n")
	//	fmt.Printf("  %v \n",buffer.String())

	return shim.Success(buffer.Bytes())

}

// 通过condition查询fncUserAuth(复杂查询)
func queryFncUserAuthByCond(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	var err error

	fmt.Println("- start query fncUserAuth by conditions")

	if len(args) < 1 {
		return shim.Error("Incorrect number of arguments. Expecting 1")
	}
	fncUserAuth1 := args[0] // 查询条件以json串传递，格式为：{"docType":"BizGldAccvalRltv","id":"id0001","createTime":"20171110",...}
	fncUserAuth := FncUserAuth{}
	err = json.Unmarshal([]byte(fncUserAuth1), &fncUserAuth)
	if err != nil {
		return shim.Error(err.Error())
	}

	if isEmptyFncUserAuth(fncUserAuth) {
		return shim.Error("The query conditions can not be null")
	}

	queryString := tranfFncUserAuthToQryStr(fncUserAuth)
	resultsIterator, err := stub.GetQueryResult(queryString) // 返回迭代器
	if err != nil {
		return shim.Error(err.Error())
	}
	defer resultsIterator.Close()

	if !resultsIterator.HasNext() {
		timestamp := time.Now().Format("2006-01-02 15:04:05")
		fmt.Printf("- can not find fncUserAuth by querystring ! %v \n", timestamp)
		return shim.Success([]byte("can not find fncUserAuth by conditions"))
	}
	var buffer bytes.Buffer
	buffer.WriteString("[") // 封装成对象数组json串格式
	bArrayMemberAlreadyWritten := false
	for resultsIterator.HasNext() {
		queryResponse, err := resultsIterator.Next()
		if err != nil {
			return shim.Error(err.Error())
		}
		if bArrayMemberAlreadyWritten == true {
			buffer.WriteString(",")
		}
		buffer.WriteString("{\"Key\":")
		buffer.WriteString("\"")
		buffer.WriteString(queryResponse.Key)
		buffer.WriteString("\"")

		buffer.WriteString(", \"Value\":")
		buffer.WriteString(string(queryResponse.Value))
		buffer.WriteString("}")
		bArrayMemberAlreadyWritten = true
	}
	buffer.WriteString("]")

	timestamp := time.Now().Format("2006-01-02 15:04:05")
	fmt.Printf("- query by conditions successfully ! %v \n", timestamp)
	//	fmt.Printf("- the query result is : \n")
	//	fmt.Printf("  %v \n",buffer.String())

	return shim.Success(buffer.Bytes())

}

// 通过fncUserAuthId查询fncUserAuth的历史（复杂查询）
func queryFncUserAuthHsyByFncUserAuthId(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	var err error
	var fncUserAuthId string

	fmt.Println("- start query fncUserAuth history by fncUserAuthId")

	if len(args) != 1 {
		return shim.Error("Incorrect number of arguments. Expecting fncUserAuthId of the fncUserAuth to query")
	}

	fncUserAuthId = strings.ToLower(args[0])

	resultsIterator, err := stub.GetHistoryForKey("FncUserAuth" + fncUserAuthId) // 返回迭代器
	if err != nil {
		return shim.Error(err.Error())
	}
	defer resultsIterator.Close()

	if !resultsIterator.HasNext() {
		timestamp := time.Now().Format("2006-01-02 15:04:05")
		fmt.Printf("- can not find fncUserAuth history by fncUserAuthId ! %v \n", timestamp)
		return shim.Success([]byte("can not find fncUserAuth history by fncUserAuthId"))
	}
	var buffer bytes.Buffer
	buffer.WriteString("[")
	bArrayMemberAlreadyWritten := false
	for resultsIterator.HasNext() {
		response, err := resultsIterator.Next()
		if err != nil {
			return shim.Error(err.Error())
		}
		if bArrayMemberAlreadyWritten == true {
			buffer.WriteString(",")
		}
		buffer.WriteString("{\"TxId\":")
		buffer.WriteString("\"")
		buffer.WriteString(response.TxId)
		buffer.WriteString("\"")

		buffer.WriteString(", \"Value\":")
		if response.IsDelete { // 若已删除则value为null
			buffer.WriteString("null")
		} else {
			buffer.WriteString(string(response.Value))
		}

		buffer.WriteString(", \"Timestamp\":")
		buffer.WriteString("\"")
		buffer.WriteString(time.Unix(response.Timestamp.Seconds, int64(response.Timestamp.Nanos)).String())
		buffer.WriteString("\"")

		buffer.WriteString(", \"IsDelete\":")
		buffer.WriteString("\"")
		buffer.WriteString(strconv.FormatBool(response.IsDelete))
		buffer.WriteString("\"")

		buffer.WriteString("}")
		bArrayMemberAlreadyWritten = true
	}
	buffer.WriteString("]")

	timestamp := time.Now().Format("2006-01-02 15:04:05")
	fmt.Printf("- query history by fncUserAuthId successfully ! %v \n", timestamp)
	//	fmt.Printf("- the query result is : \n")
	//	fmt.Printf("  %v \n",buffer.String())

	return shim.Success(buffer.Bytes())

}

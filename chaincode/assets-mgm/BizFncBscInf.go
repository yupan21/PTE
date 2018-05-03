package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"reflect"
	"strconv"
	"time"

	"github.com/hyperledger/fabric/core/chaincode/shim"
	pb "github.com/hyperledger/fabric/protos/peer"
)

/**************************************************************************************/
// 融资基本信息结构体
type BizFncBscinf struct {
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

	FncJrnlId        string  `json:"fncJrnlId"`        //融资编号
	CtrId            string  `json:"ctrId"`            //合同编号
	PdId             string  `json:"pdId"`             //产品编号
	PdNm             string  `json:"pdNm"`             //产品名称
	CstId            string  `json:"cstId"`            //客户编号
	CstNm            string  `json:"cstNm"`            //客户名称
	CntprId          string  `json:"cntprId"`          //交易对手编号
	CtrAmt           float64 `json:"ctrAmt"`           //合同金额
	CtrCcyCd         string  `json:"ctrCcyCd"`         //合同币种代码
	CtrStDt          int64   `json:"ctrStDt"`          //合同起始日期
	CtrExpDt         int64   `json:"ctrExpDt"`         //合同到期日期
	CtrAvlAmt        float64 `json:"ctrAvlAmt"`        //合同可用金额
	CtrArUseAmt      float64 `json:"ctrArUseAmt"`      //合同已用金额
	CoreAvlLmt       float64 `json:"coreAvlLmt"`       //核心企业可用金额
	CoreArUseLmt     float64 `json:"coreArUseLmt"`     //核心企业已用额度
	LndAvlLmt        float64 `json:"lndAvlLmt"`        //借款企业可用额度
	LndArUseLmt      float64 `json:"lndArUseLmt"`      //借款企业已用额度
	NtwId            string  `json:"ntwId"`            //网络编号
	NtwNm            string  `json:"ntwNm"`            //网络名称
	HgstCanFncAmt    float64 `json:"hgstCanFncAmt"`    //最高可融资金额
	BlTpCd           string  `json:"blTpCd"`           //票据类型代码
	FncImtCd         string  `json:"fncImtCd"`         //融资工具代码
	Rmrk             string  `json:"rmrk"`             //备注
	Opin             string  `json:"opin"`             //意见
	RcvPymtStCd      string  `json:"rcvPymtStCd"`      //收款状态代码
	RspbPsnId        string  `json:"rspbPsnId"`        //经办人编号
	HdlInstId        string  `json:"hdlInstId"`        //经办机构编号
	HdlDt            int64   `json:"hdlDt"`            //经办日期（营业日）
	FnsStCd          string  `json:"fnsStCd"`          //融资状态代码
	PcsStCd          string  `json:"pcsStCd"`          //流程状态代码
	WorkItemId       string  `json:"workItemId"`       //流程活动节点编号
	BsnModeCd        string  `json:"bsnModeCd"`        //业务模式代码
	PrmtEntrstdPyInd string  `json:"prmtEntrstdPyInd"` //允许受托支付标志
	PoolSt           string  `json:"poolSt"`           //池模式状态
	GldSt            string  `json:"gldSt"`            //是否金票模式
	DtSrc            string  `json:"dtSrc"`            //数据来源
	FlowNm           string  `json:"flowNm"`           //预算号

	FncRcvbInfs []FncRcvbInf `json:"fncRcvbInfs"` //融资关联的应收账款列表
	//FncRcvbInfs []map[string]interface{}
}

type FncRcvbInf struct {
	RcvbId       string  `json:"rcvbId"`       //应收账款编号
	DocId        string  `json:"docId"`        //单据编号
	CcyCd        string  `json:"ccyCd"`        //币种代码
	TrsferDt     int64   `json:"trsferDt"`     //转让日期
	TrsferAmt    float64 `json:"trsferAmt"`    //应收账款转让金额
	CanFncAmt    float64 `json:"canFncAmt"`    //可融资总金额
	ThsFncAmt    float64 `json:"thsFncAmt"`    //本次融资金额
	RcvbBal      float64 `json:"rcvbBal"`      //应收账款余额
	RcvbExdy     int64   `json:"rcvbExdy"`     //应收账款到期日
	LoanAmt      float64 `json:"loanAmt"`      //已出账金额
	LoanPercent  float64 `json:"loanPercent"`  //融资比例
	AlrdyRepyAmt float64 `json:"alrdyRepyAmt"` //已还款金额
	RspbPsnId    string  `json:"rspbPsnId"`    //经办人编号
	HdlInstId    string  `json:"hdlInstId"`    //经办机构编号
	AccValGrcPrd int64   `json:"accValGrcPrd"` //账款宽限期
	WrntCnvsInd  string  `json:"wrntCnvsInd"`  //担保转化标志
	CntprId      string  `json:"cntprId"`      //交易对手编号
	CntprNm      string  `json:"cntprNm"`      //交易对手名称
	PoolInd      string  `json:"poolInd"`      //池标志
	PoolAmt      float64 `json:"poolAmt"`      //账款池水位金额
}

// 用于解析queryString
type QryStrBizFncBscinf struct {
	Selector BizFncBscinf `json:"selector"`
}

// 判断BizFncBscinf变量是否为空
func isEmptyBizFncBscinf(arg BizFncBscinf) bool {
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

// BizFncBscinf变量变为queryString
func tranfBizFncBscinfToQryStr(arg BizFncBscinf) string {
	queryString := "{\"selector\":{\"docType\":\"BizFncBscinf\"" // 封装，头部

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
// 保存或更新bizFncBscinf
func saveOrUpdateBizFncBscinf(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	var err error
	fmt.Println("- start saveOrUpdate bizFncBscinf")

	if len(args) < 1 {
		return shim.Error("Incorrect number of arguments. Expecting 1")
	}

	bizFncBscinf := args[0]
	//fmt.Println("- the received bizFncBscinf args is :", bizFncBscinf)
	bizFncBscinf1 := BizFncBscinf{}
	err = json.Unmarshal([]byte(bizFncBscinf), &bizFncBscinf1)
	if err != nil {
		return shim.Error(err.Error())
	}

	if bizFncBscinf1.FncJrnlId == "" {
		return shim.Error("fncJrnlId can't be null")
	} else {
		bizFncBscinfFromState, err := stub.GetState("BizFncBscinf" + bizFncBscinf1.FncJrnlId)
		if err != nil {
			return shim.Error("Failed to get bizFncBscinf:" + err.Error())
		} else if bizFncBscinfFromState == nil {
			bizFncBscinf1.ObjectType = "BizFncBscinf"
			bizFncBscinf1.DelInd = "0" // 删除标志，初始值为0
			bizFncBscinfToState, err := json.Marshal(bizFncBscinf1)
			err = stub.PutState("BizFncBscinf"+bizFncBscinf1.FncJrnlId, bizFncBscinfToState)
			if err != nil {
				return shim.Error(err.Error())
			}

			timestamp := time.Now().Format("2006-01-02 15:04:05")
			fmt.Printf("- save successfully ! %v \n", timestamp)
			//		fmt.Printf("- the key of record is : BizFncBscinf%v \n",bizFncBscinf1.FncJrnlId)
			//		fmt.Printf("- the value of record is ： %v \n",string(bizFncBscinfToState))

			return shim.Success(nil)
		} else {
			bizFncBscinf2 := BizFncBscinf{}
			err = json.Unmarshal([]byte(bizFncBscinfFromState), &bizFncBscinf2)
			value1 := reflect.ValueOf(&bizFncBscinf1).Elem()
			value2 := reflect.ValueOf(&bizFncBscinf2).Elem()
			for i := 0; i < value1.NumField(); i++ {
				if !isEmpty(value1.Field(i).Interface()) {
					value2.Field(i).Set(value1.Field(i))
				}
			}
			bizFncBscinfToState, err := json.Marshal(bizFncBscinf2)
			err = stub.PutState("BizFncBscinf"+bizFncBscinf1.FncJrnlId, bizFncBscinfToState)
			if err != nil {
				return shim.Error(err.Error())
			}

			timestamp := time.Now().Format("2006-01-02 15:04:05")
			fmt.Printf("- update successfully ! %v \n", timestamp)
			//			fmt.Printf("- the key of record is : BizFncBscinf%v \n",bizFncBscinf1.FncJrnlId)
			//			fmt.Printf("- the value of record is ： %v \n",string(bizFncBscinfToState))

		}
	}
	return shim.Success(nil)
}

/**************************************************************************************/
// 保存或更新bizFncBscinfList
func saveOrUpdateBizFncBscinfList(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	var err error
	fncid := 0
	fmt.Println("- start saveOrUpdate bizFncBscinfList")

	if len(args) < 1 {
		return shim.Error("Incorrect number of arguments. Expecting 1")
	}

	bizFncBscinfList := args[0]
	// fmt.Println("- the received bizFncBscinfList args is :", bizFncBscinfList)
	bizFncBscinf1List := []BizFncBscinf{}
	err = json.Unmarshal([]byte(bizFncBscinfList), &bizFncBscinf1List)
	if err != nil {
		return shim.Error(err.Error())
	}
	fmt.Println("- the len of tx list:", len(bizFncBscinf1List))
	for _, bizFncBscinf1 := range bizFncBscinf1List {
		if bizFncBscinf1.FncJrnlId == "" {
			return shim.Error("fncJrnlId can't be null")
		} else {
			bizFncBscinfFromState, err := stub.GetState("BizFncBscinf" + bizFncBscinf1.FncJrnlId)
			if err != nil {
				return shim.Error("Failed to get bizFncBscinf:" + err.Error())
			} else if bizFncBscinfFromState == nil {
				fncid++
				bizFncBscinf1.FncJrnlId = bizFncBscinf1.FncJrnlId + strconv.Itoa(fncid)
				bizFncBscinf1.ObjectType = "BizFncBscinf"
				bizFncBscinf1.DelInd = "0" // 删除标志，初始值为0
				bizFncBscinfToState, err := json.Marshal(bizFncBscinf1)
				err = stub.PutState("BizFncBscinf"+bizFncBscinf1.FncJrnlId, bizFncBscinfToState)
				if err != nil {
					return shim.Error(err.Error())
				}

				timestamp := time.Now().Format("2006-01-02 15:04:05")
				fmt.Printf("- save %s successfully ! %v \n", bizFncBscinf1.FncJrnlId, timestamp)
				//		fmt.Printf("- the key of record is : BizFncBscinf%v \n",bizFncBscinf1.FncJrnlId)
				//		fmt.Printf("- the value of record is ： %v \n",string(bizFncBscinfToState))

				//return shim.Success(nil)
			} else {
				bizFncBscinf2 := BizFncBscinf{}
				err = json.Unmarshal([]byte(bizFncBscinfFromState), &bizFncBscinf2)
				value1 := reflect.ValueOf(&bizFncBscinf1).Elem()
				value2 := reflect.ValueOf(&bizFncBscinf2).Elem()
				for i := 0; i < value1.NumField(); i++ {
					if !isEmpty(value1.Field(i).Interface()) {
						value2.Field(i).Set(value1.Field(i))
					}
				}
				bizFncBscinfToState, err := json.Marshal(bizFncBscinf2)
				err = stub.PutState("BizFncBscinf"+bizFncBscinf1.FncJrnlId, bizFncBscinfToState)
				if err != nil {
					return shim.Error(err.Error())
				}

				timestamp := time.Now().Format("2006-01-02 15:04:05")
				fmt.Printf("- update successfully ! %v \n", timestamp)
				//			fmt.Printf("- the key of record is : BizFncBscinf%v \n",bizFncBscinf1.FncJrnlId)
				//			fmt.Printf("- the value of record is ： %v \n",string(bizFncBscinfToState))

			}
		}
	}
	return shim.Success(nil)
}

// 通过fncJrnlId查询bizFncBscinf
func queryBizFncBscinfByFncJrnlId(stub shim.ChaincodeStubInterface, args []string) pb.Response {

	var err error
	var fncJrnlId, jsonResp string

	fmt.Println("- start query bizFncBscinf by fncJrnlId")

	if len(args) != 1 {
		return shim.Error("Incorrect number of arguments. Expecting fncJrnlId of the bizFncBscinf to query")
	}

	fncJrnlId = args[0]

	bizFncBscinfFromState, err := stub.GetState("BizFncBscinf" + fncJrnlId)

	if err != nil {
		jsonResp = "{\"Error\":\"Failed to get state for " + fncJrnlId + "\"}"
		return shim.Error(jsonResp)
	} else if bizFncBscinfFromState == nil {
		jsonResp = "{\"Error\":\"bizFncBscinf does not exist: " + fncJrnlId + "\"}"
		return shim.Error(jsonResp)
	}

	var buffer bytes.Buffer // 缓存，用来保存查询结果
	buffer.WriteString("{\"Key\":")
	buffer.WriteString("\"BizFncBscinf")
	buffer.WriteString(fncJrnlId)
	buffer.WriteString("\"")
	buffer.WriteString(", \"Value\":")
	buffer.WriteString(string(bizFncBscinfFromState))
	buffer.WriteString("}")

	timestamp := time.Now().Format("2006-01-02 15:04:05")
	fmt.Printf("- query by fncJrnlId successfully ! %v \n", timestamp)
	//	fmt.Printf("- the query result is : \n")
	//	fmt.Printf("  %v \n",buffer.String())

	return shim.Success(buffer.Bytes())
}

// 通过fncJrnlId范围查询bizFncBscinf(复杂查询)
func queryBizFncBscinfByFncJrnlIdRange(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	var err error
	var startFncJrnlId, endFncJrnlId string

	fmt.Println("- start query bizFncBscinf by fncJrnlId range")

	if len(args) < 2 {
		return shim.Error("Incorrect number of arguments. Range query expect startFncJrnlId and endFncJrnlId of the bizFncBscinf to query")
	}
	startFncJrnlId = args[0]
	endFncJrnlId = args[1]

	startKey := "BizFncBscinf" + startFncJrnlId
	endKey := "BizFncBscinf" + endFncJrnlId

	resultsIterator, err := stub.GetStateByRange(startKey, endKey)
	if err != nil {
		return shim.Error(err.Error())
	}
	defer resultsIterator.Close() // 迭代器用完需关闭！！

	if !resultsIterator.HasNext() {
		timestamp := time.Now().Format("2006-01-02 15:04:05")
		fmt.Printf("- can not find bizFncBscinf by fncJrnlId range ! %v \n", timestamp)
		return shim.Success([]byte("can not find bizFncBscinf by fncJrnlId range"))
	}
	var buffer bytes.Buffer
	buffer.WriteString("[") // 对查询结果进行封装，封装为对象数组json格式
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
	fmt.Printf("- query range by startFncJrnlId and endFncJrnlId successfully ! %v \n", timestamp)
	//	fmt.Printf("- the query result is : \n")
	//	fmt.Printf("  %v \n",buffer.String())

	return shim.Success(buffer.Bytes()) // 最终，结果以[]byte形式返回

}

// 通过querystring查询bizFncBscinf(复杂查询)
func queryBizFncBscinfByQryStr(stub shim.ChaincodeStubInterface, args []string) pb.Response {

	var err error
	var queryString string

	//	fmt.Println("- start query gldAccvalRltv by queryString, the queryString is : \n %v \n",queryString )
	fmt.Println("- start query bizFncBscinf by queryString")

	if len(args) != 1 {
		return shim.Error("Incorrect number of arguments. Expecting querystring of the bizFncBscinf to query")
	}
	queryString = args[0]

	if queryString == "" { // 判定querystring是否为空
		return shim.Error("The queryString can not be null ")
	}
	qryStrBizFncBscinf := QryStrBizFncBscinf{}
	err = json.Unmarshal([]byte(queryString), &qryStrBizFncBscinf)
	if err != nil {
		return shim.Error(err.Error())
	}
	if isEmptyBizFncBscinf(qryStrBizFncBscinf.Selector) { // 判断queryString中有没有查询条件
		return shim.Error("The selector of queryString can not be null ")
	}

	querystring := tranfBizFncBscinfToQryStr(qryStrBizFncBscinf.Selector)

	resultsIterator, err := stub.GetQueryResult(querystring) // 返回迭代器，querystring格式：{"selector":{"docType":"BizGldAccvalRltv","CreateUser":"jzk",...}}
	if err != nil {
		return shim.Error(err.Error())
	}
	defer resultsIterator.Close()

	if !resultsIterator.HasNext() {
		timestamp := time.Now().Format("2006-01-02 15:04:05")
		fmt.Printf("- can not find bizFncBscinf by querystring ! %v \n", timestamp)
		return shim.Success([]byte("can not find bizFncBscinf by querystring"))
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

// 通过condition查询bizFncBscinf(复杂查询)
func queryBizFncBscinfByCond(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	var err error

	fmt.Println("- start query bizFncBscinf by conditions")

	if len(args) < 1 {
		return shim.Error("Incorrect number of arguments. Expecting 1")
	}
	bizFncBscinf1 := args[0] // 查询条件以json串传递，格式为：{"docType":"BizGldAccvalRltv","id":"id0001","createTime":"20171110",...}
	bizFncBscinf := BizFncBscinf{}
	err = json.Unmarshal([]byte(bizFncBscinf1), &bizFncBscinf)
	if err != nil {
		return shim.Error(err.Error())
	}

	if isEmptyBizFncBscinf(bizFncBscinf) {
		return shim.Error("The query conditions can not be null")
	}

	queryString := tranfBizFncBscinfToQryStr(bizFncBscinf)
	resultsIterator, err := stub.GetQueryResult(queryString) // 返回迭代器
	if err != nil {
		return shim.Error(err.Error())
	}
	defer resultsIterator.Close()

	if !resultsIterator.HasNext() {
		timestamp := time.Now().Format("2006-01-02 15:04:05")
		fmt.Printf("- can not find bizFncBscinf by querystring ! %v \n", timestamp)
		return shim.Success([]byte("can not find bizFncBscinf by conditions"))
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

// 通过fncJrnlId查询bizFncBscinf的历史（复杂查询）
func queryBizFncBscinfHsyByFncJrnlId(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	var err error
	var fncJrnlId string

	fmt.Println("- start query bizFncBscinf history by fncJrnlId")

	if len(args) != 1 {
		return shim.Error("Incorrect number of arguments. Expecting fncJrnlId of the bizFncBscinf to query")
	}

	fncJrnlId = args[0]

	resultsIterator, err := stub.GetHistoryForKey("BizFncBscinf" + fncJrnlId) // 返回迭代器
	if err != nil {
		return shim.Error(err.Error())
	}
	defer resultsIterator.Close()

	if !resultsIterator.HasNext() {
		timestamp := time.Now().Format("2006-01-02 15:04:05")
		fmt.Printf("- can not find bizFncBscinf history by fncJrnlId ! %v \n", timestamp)
		return shim.Success([]byte("can not find bizFncBscinf history by fncJrnlId"))
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
	fmt.Printf("- query history by fncJrnlId successfully ! %v \n", timestamp)
	//	fmt.Printf("- the query result is : \n")
	//	fmt.Printf("  %v \n",buffer.String())

	return shim.Success(buffer.Bytes())

}

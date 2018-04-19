package main

import (
	"github.com/hyperledger/fabric/core/chaincode/shim"
	pb "github.com/hyperledger/fabric/protos/peer"
	//	"strconv"
	"fmt"
	"time"
)

// chaincode操作类型
type ChainCodeImpl struct {
}

// 初始化方法
func (c *ChainCodeImpl) Init(stub shim.ChaincodeStubInterface) pb.Response {

	timestamp := time.Now().Format("2006-01-02 15:04:05")
	fmt.Println("init complete !", timestamp)

	return shim.Success(nil)
}

// 外部调用统一入口
func (c *ChainCodeImpl) Invoke(stub shim.ChaincodeStubInterface) pb.Response {
	function, args := stub.GetFunctionAndParameters()
	timestamp := time.Now().Format("2006-01-02 15:04:05")
	fmt.Println("invoke is running "+function, timestamp)

	switch function {
	// 结构体1：BizFncBscinf
	case "saveOrUpdateBizFncBscinf":
		return saveOrUpdateBizFncBscinf(stub, args)
	case "saveOrUpdateBizFncBscinfList":
		return saveOrUpdateBizFncBscinfList(stub, args)
	case "queryBizFncBscinfByFncJrnlId":
		return queryBizFncBscinfByFncJrnlId(stub, args)
	case "queryBizFncBscinfByFncJrnlIdRange":
		return queryBizFncBscinfByFncJrnlIdRange(stub, args)
	case "queryBizFncBscinfByQryStr":
		return queryBizFncBscinfByQryStr(stub, args)
	case "queryBizFncBscinfByCond":
		return queryBizFncBscinfByCond(stub, args)
	case "queryBizFncBscinfHsyByFncJrnlId":
		return queryBizFncBscinfHsyByFncJrnlId(stub, args)

		// 结构体1：FncUserAuth
	case "saveOrUpdateFncUserAuth":
		return saveOrUpdateFncUserAuth(stub, args)
	case "saveOrUpdateFncUserAuthList":
		return saveOrUpdateFncUserAuthList(stub, args)
	case "deleteFncUserAuth":
		return deleteFncUserAuth(stub, args)
	case "queryFncUserAuthByFncUserAuthId":
		return queryFncUserAuthByFncUserAuthId(stub, args)
	case "queryFncUserAuthByQryStr":
		return queryFncUserAuthByQryStr(stub, args)
	case "queryFncUserAuthByCond":
		return queryFncUserAuthByCond(stub, args)
	case "queryFncUserAuthHsyByFncUserAuthId":
		return queryFncUserAuthHsyByFncUserAuthId(stub, args)

	// 所调用的方法未定义
	default:
		fmt.Println("invoke did not find func: " + function)
		return shim.Error("Received unknown function invocation")
	}
}

// chaincode入口
func main() {
	timestamp := time.Now().Format("2006-01-02 15:04:05")
	err := shim.Start(new(ChainCodeImpl))
	if err != nil {
		fmt.Printf("Error starting chaincode: %s  %s", err, timestamp)
	}
}

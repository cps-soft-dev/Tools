#regedit add/del Tools 
#定位文件格式：csv（逗号切分）
#定义文件名称：RegSet.csv
#项目说明：路径，项目名，项目类型，项目值，用户，操作（Add/Del）,功能描述
#regPath,regName,regType,regData,user,operating,displayName
#工具功能：读取定义文件中内容，根据操作，用户，项目类型，调用不同的注册表操作更新注册表
#1.定位读取条件
#   用户列包含admin
#      1.1.操作=Add ：调用reg add （根据类型设定不同参数）
#      1.2.操作=Del ：调用reg del （根据类型设定不同参数）
#2.定位读取条件
#   用户列包含user
#      1.1.reg load HKU\Temp 该用户的ntuser.dat
#      1.2.regPath中的HKEY_CURRENT_USER替换成HKU\Temp
#      1.3.操作=Add ：调用reg add （根据类型设定不同参数）
#      1.4.操作=Del ：调用reg del （根据类型设定不同参数）
#      1.5.调用reg uload HKU\Temp
#3.用1和2类似的方式取出注册表的值进行确认
#   确认结果log样式
#     （OK）功能描述 *取得值和定位文件中的相同
#     （NG）功能描述 *取得值和定义文件中的不同 
#

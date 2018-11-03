from pymongo import MongoClient
from bson.objectid import ObjectId

client = MongoClient()

db = client.pretty

contracts = db.contract
users = db.users

def createContract(ownerID, sLat, sLong, eLat, eLon, price):
	contract = {
		"ownerID" : ownerID,
		"acceptID" : -1,
		"startLocation" :[sLat, sLong],
		"endLocation" : [eLat, eLon],
		"price" : price,
		"valid" : true,
		"active" : false,
	}

	result = contracts.insert(contract);
	return ObjectID.toString(result);

def createUser(name, password,  userID, rating):
	user = {
		"name" : name,
		"password" : password,
		"username" : userID,
		"rating" : rating
	}
	result = users.insert(user)
	
	return ObjectID.toString(result);


def acceptContract(userID, contractID):
	objID = ObjectID(contractID)
	found = contracts.find( {"$and" :[{"_id" : objID}, {"valid": true}]}).count()

	if found > 0:
		contracts.update({"_id": objID}, { "$set" : {"valid": false, "active": true, "acceptID": userID } })
		return true
	else: 
		return false

def completeContract(contractID):
	objID = ObjectID(contractID)
	found = contracts.find( {"$and" : [{"_id" : objID}, {"active": true}]} ).count()

	if found > 0:
		contracts.update( {"_id" : objID}, { "$set" : {"active" : false}})
		return true
	else: 
		return false




def validLogin(username, password):
	userProfile = users.find_one({"screenName" : username})
	for attribute in userProfile:
		passw = attribute.get("password")

	if password == passw: 
		return [true, ObjectID.toString(userProfile)]
	else: 
		return [false, -1]



def getContract(contractID):
	contract = contracts.find_one({"_id": ObjectID(contractID)})
	
	for data in contract:
		toReturn = [data.get("owner"), data.get("startLocation"), data.get("endLocation"), data.get("price")]

	return toReturn

def getUser(blockID):
	contract = contracts.find({"_id": ObjectID(blockID)})
	
	for data in contract:
		toReturn = [data.get("name"), data.get("password"), data.get("screenName"), data.get("rating")]

	return toReturn



#createContract("Theo" , 20, 20, 60, 40, 100)
#createUser("Arjun", "arjun", "arjunmishra", 0)
#getContract("Theo")





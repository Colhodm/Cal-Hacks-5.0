
from pymongo import MongoClient, GEO2D
from bson.objectid import ObjectId

client = MongoClient()

db = client.pretty

contracts = db.contract
users = db.users

contracts.create_index([("startLocation", GEO2D)])
contracts.create_index([("endLocation", GEO2D)])

def createContract(ownerID, sLat, sLong, eLat, eLon, price, title, description):
	contract = {
		"ownerID" : ownerID,
		"acceptID" : -1,
		"startLocation" :[sLat, sLong],
		"endLocation" : [eLat, eLon],
		"price" : price,
		"title" : title,
		"description" : description, 
		"valid" : True,
		"active" : False,
	}

	result = contracts.insert(contract);
	return str(result);

def createUser(name, password,  userID, rating):
	found = users.find({"username" :userID}).count()
	if found: 
		return -1

	user = {
		"name" : name,
		"password" : password,
		"username" : userID,
		"rating" : rating
	}
	result = users.insert(user)
	print str(result);
	
	return str(result);


def acceptContract(userID, contractID):
	objID = ObjectId(contractID)
	found = contracts.find( {"$and" :[{"_id" : objID}, {"valid": True}]}).count()

	if found > 0:
		contracts.update({"_id": objID}, { "$set" : {"valid": False, "active": True, "acceptID": userID } })
		return True
	else: 
		return False

def completeContract(contractID):
	objID = ObjectId(contractID)
	found = contracts.find( {"$and" : [{"_id" : objID}, {"active": True}]} ).count()

	if found > 0:
		contracts.update( {"_id" : objID}, { "$set" : {"active" : False}})
		return True
	else: 
		return False




def validLogin(username, password):
	found = users.find_one({"$and" :[{"username" : username, "password": password}] })

	if found :
		return str(found.get('_id'))
	else: 
		return -1


def getContractSpatial(lat, lon, radius) :
	query = contracts.find( {"$and" :[{"valid": True},{"startLocation": {"$within": {"$center": [[lat, lon], radius]}}} ]})

	return query



def getContract(contractID):
	contract = contracts.find_one({"_id": ObjectId(contractID)})
	
	for data in contract:
		toReturn = [data.get("owner"), data.get("startLocation"), data.get("endLocation"), data.get("price")]

	return toReturn

def getUser(blockID):
	contract = contracts.find({"_id": ObjectId(blockID)})
	
	for data in contract:
		toReturn = [data.get("name"), data.get("password"), data.get("screenName"), data.get("rating")]

	return toReturn



#createContract("5bdde74ab7ae36d406d6ea65" , 20, 20, 60, 40, 100)
#createUser("Theo", "pass", "theoluan", 0)
#acceptContract("5bdde74ab7ae36d406d6ea65", "5bdde93fb7ae36d449895550")
#print validLogin("theoluan", "not")
#getContract("Theo")





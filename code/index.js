/**
* This is a the code for the simple lambda function the terraform demo deploys.
* Remember, it's always a good idea to make sure your artifacts are published BEFORE
* you start to Terraform anything.
*/
exports.handler = (event, context, callback) => {
	// it's true though
	var responseBody = { the_greatest_of_all_time: "Kanye West" };

    var response = {
        "statusCode": 200,
        "headers": {
            "Access-Control-Allow-Origin": "*",
            "Content-Type": "application/json"
        },
        "body": JSON.stringify(responseBody),
        "isBase64Encoded": false
    };

    callback(null, response);
}
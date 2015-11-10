var postmark = require("postmark");
var client = new postmark.Client("dde9a1fd-5b8e-43f9-9761-5850fb993a78");

exports.sendEmail = function(req, res) {
	console.log("Sending email");
	var email = req.query.email;
	console.log(email);

	client.sendEmail({
		"From": "betaRequests@myVerbatm.com",
		"To": "betaRequests@myVerbatm.com",
		"Subject": "Requesting Beta Test Info",
		"TextBody": email,
		"Attachments": []

	}, function(error, success) {
		if(error) {
			console.error("Unable to send via postmark: " + error.message);
			res.status(200).send("Sorry, we were unable to send your email.")
		} else {
			console.info("Sent to postmark for delivery");
			res.status(200).send("Email sent");
		}
	});
};




require("cloud/app.js");

var twilioAccountSid = 'AC3c9e28981c3e0a9d39ea4c2420b7474c';
var twilioAuthToken = '31499c1d4a9065dd07c6512ebd8d7855';
var twilioPhoneNumber = '4259708446';
var secretPasswordToken = 'dQg7cZKt5O8F6VNRbdjW';

var language = "en";
var languages = ["en", "es", "ja", "kr", "pt-BR"];

var twilio = require('twilio')(twilioAccountSid, twilioAuthToken);

Parse.Cloud.define("sendCode", function(req, res) {
	var phoneNumber = req.params.phoneNumber;
	phoneNumber = phoneNumber.replace(/\D/g, '');

	var lang = req.params.language;
  if(lang !== undefined && languages.indexOf(lang) != -1) {
		language = lang;
	}

	if (!phoneNumber || (phoneNumber.length != 10 && phoneNumber.length != 11)) return res.error('Invalid Parameters');
	Parse.Cloud.useMasterKey();
	var query = new Parse.Query(Parse.User);
	query.equalTo('username', phoneNumber + "");
	query.first().then(function(result) {
		var min = 1000; var max = 9999;
		var num = Math.floor(Math.random() * (max - min + 1)) + min;

		if (result) {
			result.setPassword(secretPasswordToken + num);
			result.set("language", language);
			result.save().then(function() {
				return sendCodeSms(phoneNumber, num, language);
			}).then(function() {
				res.success({});
			}, function(err) {
				res.error(err);
			});
		} else {
			var user = new Parse.User();
			user.setUsername(phoneNumber);
			user.setPassword(secretPasswordToken + num);
			user.set("language", language);
			user.setACL({});
			user.save().then(function(a) {
				return sendCodeSms(phoneNumber, num, language);
			}).then(function() {
				res.success({});
			}, function(err) {
				res.error(err);
			});
		}
	}, function (err) {
		res.error(err);
	});
});

Parse.Cloud.define("logIn", function(req, res) {
	Parse.Cloud.useMasterKey();

	var phoneNumber = req.params.phoneNumber;
	phoneNumber = phoneNumber.replace(/\D/g, '');

	if (phoneNumber && req.params.codeEntry) {
		Parse.User.logIn(phoneNumber, secretPasswordToken + req.params.codeEntry).then(function (user) {
			res.success(user.getSessionToken());
		}, function (err) {
			res.error(err);
		});
	} else {
		res.error('Invalid parameters.');
	}
});

// Sets default values to num follows and num following
Parse.Cloud.beforeSave("ChannelClass", function(request, response) {
  if (!request.object.get("ChannelNumFollows")) {
    request.object.set("ChannelNumFollows", 0);
  }
  if (!request.object.get("ChannelNumFollowing")) {
  	request.object.set("ChannelNumFollowing", 0);
  }
  if (!request.object.get("Featured")) {
  	request.object.set("Featured", false);
  }
  response.success();
});

// Do not allow duplicate follows, likes, or notifications
var NotificationClass = Parse.Object.extend("NotificationClass");
var LikeClass = Parse.Object.extend("LikeClass");
var FollowClass = Parse.Object.extend("FollowClass");

Parse.Cloud.beforeSave("NotificationClass", function(request, response) {
	// Let existing object updates go through
	if (!request.object.isNew()) {
      response.success();
    }
	var query = new Parse.Query(NotificationClass);
	query.equalTo("NotificationSender", request.object.get("NotificationSender"));
	query.equalTo("NotificationReceiver", request.object.get("NotificationReceiver"));
	var notificationType = request.object.get("NotificationType");
	query.equalTo("NotificationType", notificationType);
	// If this is a like or a share notification
	if (notificationType == 2 || notificationType == 3 || notificationType == 5) {
		query.equalTo("NotificationPost", request.object.get("NotificationPost"));
	}
	query.first().then(function(existingObject) {
      if (existingObject) {
        response.error("Existing notification");
      } else {
        response.success();
      }
    });
});

Parse.Cloud.beforeSave("LikeClass", function(request, response) {
	// Let existing object updates go through
	if (!request.object.isNew()) {
      response.success();
    }
	var query = new Parse.Query(LikeClass);
	query.equalTo("UserLiking", request.object.get("UserLiking"));
	query.equalTo("PostLiked", request.object.get("PostLiked"));
	query.first().then(function(existingObject) {
      if (existingObject) {
        response.error("Existing like");
      } else {
        response.success();
      }
    });
});

Parse.Cloud.beforeSave("FollowClass", function(request, response) {
	// Let existing object updates go through
	if (!request.object.isNew()) {
      response.success();
    }
	var query = new Parse.Query(FollowClass);
	query.equalTo("ChannelFollowed", request.object.get("ChannelFollowed"));
	query.equalTo("UserFollowing", request.object.get("UserFollowing"));
	query.first().then(function(existingObject) {
      if (existingObject) {
        response.error("Existing follow object");
      } else {
        response.success();
      }
    });
});

function sendCodeSms(phoneNumber, code, language) {
	var prefix = "+1";
	if(typeof language !== undefined && language == "ja") {
		prefix = "+81";
	} else if (typeof language !== undefined && language == "kr") {
		prefix = "+82";
		phoneNumber = phoneNumber.substring(1);
	} else if (typeof language !== undefined && language == "pt-BR") {
		prefix = "+55";
  }

	var promise = new Parse.Promise();
	twilio.sendSms({
		to: prefix + phoneNumber.replace(/\D/g, ''),
		from: twilioPhoneNumber.replace(/\D/g, ''),
		body: 'Your login code for Verbatm is ' + code
	}, function(err, responseData) {
		if (err) {
			console.log(err);
			promise.reject(err.message);
		} else {
			promise.resolve();
		}
	});
	return promise;
}

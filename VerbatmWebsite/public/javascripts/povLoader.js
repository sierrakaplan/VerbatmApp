function init() {
	var apiRoot = 'https://verbatmapp.appspot.com/_ah/api/';
	gapi.client.setApiKey('AIzaSyCXCXxackDD1741IuU9Kv7Dgpt8Q2pbq3k');
	gapi.client.load('verbatmApp', 'v1', apiLoaded, apiRoot);
}

function apiLoaded() {
	console.log("POV ID: " + povID);
	gapi.client.verbatmApp.pov.getPOV({
		'id': povID
	}).execute(povLoaded);
}

function povLoaded(pov) {
	console.log("POV: ");
	console.log(pov);

	document.title = 'Verbatm | ' + pov.title;
	gapi.client.verbatmApp.pov.getPagesFromPOV({
		'id': pov.id
	}).execute(pageListLoaded);
	gapi.client.verbatmApp.verbatmuser.getUser({
		'id': pov.creatorUserId
	}).execute(authorLoaded);
}

function pageListLoaded(pageListWrapper) {
	console.log("Pages: ");
	console.log(pageListWrapper);

	var pages = pageListWrapper.pages;
	for (var i=0; i < pages.length; i++) {
		var page = pages[i];
		var index = page.indexInPOV;
		var imageIds = page.imageIds;

		for (var j=0; j < imageIds.length; j++) {
			var imageID = imageIds[j];
			loadImage(imageID).then(function(result) {
				console.log(result);
			}).catch(function(err) {
				console.log(err);
			});
		}
		var videoIDs = page.videoIDs;
	}
}

function authorLoaded(verbatmUser) {
	console.log("Author: ");
	console.log(verbatmUser);
	document.title = document.title + ' by ' + verbatmUser.name;
}

function loadPageFromGTLPage(gtlPage) {

	return new Page(indexInPOV, images, videos);
}

function loadImage(imageID) {
	var promise = new Promise(function(resolve, reject) {
	  gapi.client.verbatmApp.image.getImage({
	  	'id': imageID
	  }).execute(function(image) {
		  if (image) {
		    console.log("Image loaded successfully!");
		    resolve(image);
		  }
		  else {
		    reject(Error("Couldn't load image"));
		  }
	  });
	});
	return promise;
}
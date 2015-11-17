function init() {
	console.log(povID);
	var apiRoot = 'https://verbatmapp.appspot.com/_ah/api/';
	console.log(window.location.host);
	gapi.client.setApiKey('AIzaSyCXCXxackDD1741IuU9Kv7Dgpt8Q2pbq3k');
	gapi.client.load('verbatmApp', 'v1', apiLoaded(), apiRoot);
}

function apiLoaded() {
	console.log(gapi.client);
	gapi.client.verbatmApp.pov.getPOV({
		'identifier': povID
	}).execute(function(response) {
		console.log(response);
	});
}
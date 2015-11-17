exports.view = function(req, res) {
	var povID = req.params.pov_id;
  	console.log("POV id: " + povID);
	res.render('storyviewer', {povID: povID});
};
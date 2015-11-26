
exports.view = function(req, res) {
	var povID = req.params.pov_id;
  	console.log("POV id: " + povID);
  	// TODO: make title the title of the story
  	var title = 'Verbatm | Story ' + povID;
	res.render('storyviewer', {title: title, povID: povID});
};

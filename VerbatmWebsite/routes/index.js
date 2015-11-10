exports.view = function(req, res){
	var title = 'Verbatm';
	res.render('index', {title: title, section: '#home'});
};
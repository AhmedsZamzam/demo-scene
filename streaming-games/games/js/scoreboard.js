function fillScoreboardPage(storageManager) {
	var playersScores= storageManager.getPlayersScores();
	if(typeof playersScores !== 'undefined'){
		var headers = ["Rank","Name", "Score", "Losses"];
		document.getElementById('scoreboard').innerHTML = json2table(playersScores, 'table', headers);
	}
}

function loadScoreboard(storageManager) {
	var gameName = storageManager.getGameName();
	loadSummaryStats(gameName,function(highestScore, usersSet) {
		
		getScoreboardJson(gameName, usersSet, function(playersScores) {
			
			storageManager.setPlayersScores(playersScores);
			
		});
	});

}

function json2table(json, classes, headers) {

	var headerRow = '';
	var bodyRows = '';
	classes = classes || '';

	function capitalizeFirstLetter(string) {
	  return string.charAt(0).toUpperCase() + string.slice(1);
	}

	headers.map(function(col) {
	  headerRow += '<th>' + capitalizeFirstLetter(col) + '</th>';
	});

	json.forEach((row, index) => {
		bodyRows += '<tr>';
		bodyRows += '<td>#' + (index+1) + '</td>';
		bodyRows += '<td>' + row.user + '</td>';
		bodyRows += '<td>' + row.score + '</td>';
		bodyRows += '<td>' + row.losses + '</td>';
		bodyRows += '</tr>';
	});

	return '<table class="' +
		   classes +
		   '"><thead><tr>' +
		   headerRow +
		   '</tr></thead><tbody>' +
		   bodyRows +
		   '</tbody></table>';

}
//google.load('visualization','1',{'packages':['treemap','corechart','orgchart']});

// Set callback to run when the library is loaded
//google.setOnLoadCallback(drawChart);

// Callback then creates and populates charts
function drawChart() {

	//Create data for treemap
	var tree_data = new google.visualization.arrayToDataTable([
          ['Location', 'Parent', 'Market trade volume (size)', 'Market increase/decrease (color)'],
          ['Global',    null,                 0,                               0],
          ['America',   'Global',             0,                               0],
          ['Europe',    'Global',             0,                               0],
          ['Asia',      'Global',             0,                               0],
          ['Australia', 'Global',             0,                               0],
          ['Africa',    'Global',             0,                               0],
          ['Brazil',    'America',            11,                              10],
          ['USA',       'America',            52,                              31],
          ['Mexico',    'America',            24,                              12],
          ['Canada',    'America',            16,                              -23],
          ['France',    'Europe',             42,                              -11],
          ['Germany',   'Europe',             31,                              -2],
          ['Sweden',    'Europe',             22,                              -13],
          ['Italy',     'Europe',             17,                              4],
          ['UK',        'Europe',             21,                              -5],
          ['China',     'Asia',               36,                              4],
          ['Japan',     'Asia',               20,                              -12],
          ['India',     'Asia',               40,                              63],
          ['Laos',      'Asia',               4,                               34],
          ['Mongolia',  'Asia',               1,                               -5],
          ['Israel',    'Asia',               12,                              24],
          ['Iran',      'Asia',               18,                              13],
          ['Pakistan',  'Asia',               11,                              -52],
          ['Egypt',     'Africa',             21,                              0],
          ['S. Africa', 'Africa',             30,                              43],
          ['Sudan',     'Africa',             12,                              2],
          ['Congo',     'Africa',             10,                              12],
          ['Zaire',     'Africa',             8,                               10]
    ]);
	
	// Create data for org chart
	var org_data = new google.visualization.DataTable();

	org_data.addColumn('string', 'Name');
    org_data.addColumn('string', 'Manager');
    org_data.addColumn('string', 'ToolTip');
    org_data.addRows([
      [{v:'Mike', f:'Mike<div style="color:red; font-style:italic">President</div>'}, '', 'The President'],
      [{v:'Jim', f:'Jim<div style="color:red; font-style:italic">Vice President</div>'}, 'Mike', 'VP'],
      ['Alice', 'Mike', ''],
      ['Bob', 'Jim', 'Bob Sponge'],
      ['Carol', 'Bob', '']
    ]);

    // Create tree chart
    var tree_chart = new google.visualization.TreeMap(document.getElementById('tree_div'));
    tree_chart.draw(tree_data, {
		  minColor: '#f00',
          midColor: '#ddd',
          maxColor: '#0d0',
          headerHeight: 15,
          fontColor: 'black',
          showScale: true});
	

    //var org_chart = new google.visualization.OrgChart(document.getElementById('org_div'));
    //org_chart.draw(org_data, null);


}
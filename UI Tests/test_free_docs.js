var PIN = "bxlhqo7l";
var target = UIATarget.localTarget();
var isSimulator = target.model().indexOf("Simulator") != -1;

UIATarget.onAlert = function onAlert(alert) {
    var title = alert.name();
	
	if (title == "Switch User Account") {
		var textfield;
		if (isSimulator) {
			textfield = alert.images()[0].textFields()[0].textFields()[0];
		}
		else {
			textfield = alert.images()[0].textFields()[0];
		}
		
		textfield.setValue(PIN);
		alert.buttons()["OK"].tap();
		return true;
	}
	else {
		return false;
	}
}

var testName = "Free Document Test";
UIALogger.logStart(testName);


// open menu
target.frontMostApp().navigationBar().leftButton().tap();

// tap PIN login button
target.frontMostApp().mainWindow().buttons()["PIN Login"].tap();

// alert should now be handled

UIATarget.localTarget().delay(5);

// tap first item in collection view
target.frontMostApp().mainWindow().collectionViews()[0].tapWithOptions({tapOffset:{x:0.26, y:0.32}});

// preview should now be open. tap "free" button
var button = target.frontMostApp().mainWindow().scrollViews()[0].buttons()["Free"];
if (button.isValid()) {
	UIALogger.logMessage("Detected 'Free' button.");
	button.tap();
}
else {
	UIALogger.logMessage("Could not detected 'Free' button.");
	UIALogger.logFail(testName);
}


// document should now be open. tap in the document to reveal toolbar
target.frontMostApp().mainWindow().scrollViews()[0].elements()[0].tap();
UIATarget.localTarget().delay(1);

// tap the "close" button
target.frontMostApp().navigationBar().buttons()["Close"].tap();


UIALogger.logPass(testName);

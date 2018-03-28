// Don't load until after the code in the window has loaded.
//  because we have to be sure that jquery, google maps etc. javascripts have been loaded


// Display a dynamic Google map
//  centerCoordinates: the initial center for the map.
//   (= Stockholm if none given  [59.32932349999999, 18.0685808])
//  markers = an array of markers to display on the map
//  icon = the icon to use for each of the markers
//
//  If there is only 1 marker for the map, center the map on that marker
//  else display all of the markers,and so the center is automatically
//   determined by the center of all of them.
//
function initCenteredMap(centerCoordinates, markers, icon) {

    var mapCenter = {lat: 59.3293235, lng: 18.0685808};

    var marks = markers === null ? [] : markers;


    if (centerCoordinates === null) {
        // try to get the user's coordinates
        if (navigator.geolocation) {
            navigator.geolocation.getCurrentPosition(function (position) {
                mapCenter = new google.maps.LatLng(position.coords.latitude,
                    position.coords.longitude);
            });
        }
    }
    else {
        mapCenter = centerCoordinates;
    }

    var map = new google.maps.Map(document.getElementById('map'), {
        center: mapCenter,
        zoom: 13
    });

    var bounds = new google.maps.LatLngBounds();

    addMarkersToMap(map, marks, bounds, icon);

    //now fit the map to the newly inclusive bounds
    // this will zoom in too far if there's only 1 marker
    if (marks.length > 1) {
        map.fitBounds(bounds);
    }

}


// add the markers to the map that is defined on the page with id = 'map'
function addMarkersToMap(map, markers, bounds, icon) {

    // if the map doesn't exist, do nothing
    if (document.getElementById('map') !== null) {

        var marks = markers === null ? [] : markers;
        var bound = bounds === null ? new google.maps.LatLngBounds() : bounds;


        for (var i = 0, len = marks.length; i < len; i++) {

            var position = {
                lat: marks[i].latitude,
                lng: marks[i].longitude
            };

            addMarker(position, map, marks[i].text, icon);

            //extend the bounds to include the position for this marker
            bound.extend(position);
        }
    }

}


// get the text from element with id = element_id
//  if there is no element_id in the document, return an empty string
function getMarkerText(elementId) {
    var text = "";

    if (document.getElementById(elementId) !== null) {
        text = document.getElementById(elementId).childNodes[0].nodeValue;
    }
    return text.trim();
}


// get the value for the element with id element_id and convert it to a Number
//  If there is no element_id in the document, show an error on the console
function getNumber(elementId) {

    if (document.getElementById(elementId) !== null) {
        return parseFloat(document.getElementById(elementId).childNodes[0].nodeValue);
    } else {
        console.error("Expected document to have an element with id '" + elementId + "' but it did not.");
    }

}


// Create a marker. Optionally, set the icon to be used for it
// When it's clicked, pop-up a box with text in it
function addMarker(coordinates, map, text, icon) {
    var marker;

    marker = new google.maps.Marker({
        position: coordinates,
        map: map,
        icon: icon
    });


    // don't create a pop-up box if there's no text to display
    if (text !== "") {
        google.maps.event.addListener(marker, "click", function () {
            createInfoWindow(text).open(map, marker);
        });
    }

    return marker;
}


// pop-up window with text
function createInfoWindow(text) {
    return new google.maps.InfoWindow({
        content: text
    });
}

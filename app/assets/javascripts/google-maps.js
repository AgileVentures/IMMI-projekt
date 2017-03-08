
// Create a map with a marker and center the map at the marker.
//
//  The coordinates and text for the marker are taken from elements in the document
//   * latitude comes from an element with id 'location-latitude'
//   * longitude comes from an element with id 'location-longitude'
//   * text comes from an element with id 'marker-text'
//
//    Example of HTML that the document might have:
//      ...
//     <h2 id="marker-text">PuppyPuzzles-R-Us</h2>
//
//     <div id="marker-text" class="hidden"><strong>PuppyPuzzles-R-Us</strong><br><p>We have the most entertaining puppy puzzles on the planet!</p><p><em>A tired puppy is a good puppy</em></p></div>
///
//     <p> <b>Coordinates:</b>
//            <span id="location-latitude">59.31</span>
//    ,
//            <span id="location-longitude">18.0707811</span>
//    </p>
//
//  If there is no text in the 'marker-text' element, no pop-up box will be created.
//
function initMap() {

    var coordinates = {lat: getNumber('location-latitude'), lng: getNumber('location-longitude')};

    var map = new google.maps.Map(document.getElementById('map'), {
        center: coordinates,
        zoom: 14
    });

    var marker_text = getMarkerText('marker-text');

    var marker = addMarker(coordinates, map, marker_text);

}


// get the text from element with id = element_id
//  if there is no element_id in the document, return an empty string
function getMarkerText(element_id) {
    var text = '';

    if (document.getElementById(element_id) !== null) {
        text = document.getElementById(element_id).childNodes[0].nodeValue;
    }
    return text.trim();
}


// get the value for the element with id element_id and convert it to a Number
//  If there is no element_id in the document, show an error on the console
function getNumber(element_id) {

    if (document.getElementById(element_id) !== null) {
        return parseFloat(document.getElementById(element_id).childNodes[0].nodeValue)
    } else {
        console.error("Expected document to have an element with id '" + element_id + "' but it did not.");
    }

}



// create a marker.  When it's clicked, pop-up a box with text in it
function addMarker(coordinates, map, text) {
    var marker;

    marker = new google.maps.Marker({
        position: coordinates,
        map: map
    });


    // don't create a pop-up box if there's no text to display
    if (text !==""){
        google.maps.event.addListener(marker, 'click', function () {
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

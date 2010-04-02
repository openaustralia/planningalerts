//#############################################################################
// Begin class MQBrowser
//#############################################################################
/**
 * Constructs a new MQBrowser object.
 * @class Class that will contain all information about
 * the browser in which the code is running.
 * @private
 */
function MQBrowser(){
   /** @type String
    */
   this.name       = null;
   /** @type String
    */
   this.version    = null;
   /** @type String
    */
   this.os       = null;
   /** @type String
    */
   this.appname    = null;
   /** @type String
    */
   this.appVersion = null;
   /** @type String
    */
   this.vMajor    = null;
   /** @type Boolean
    */
   this.isNS       = null;
   /** @type Boolean
    */
   this.isNS4      = null;
   /** @type Boolean
    */
   this.isNS6      = null;
   /** @type Boolean
    */
   this.isIE       = null;
   /** @type Boolean
    */
   this.isIE4      = null;
   /** @type Boolean
    */
   this.isIE5      = null;
   /** @type Boolean
    */
   this.isDOM      = null;
   /** @type Boolean
    */
   this.isSafari   = null;
   /** @type String
    */
   this.platform   = null;
}
// End class MQBrowser


//#############################################################################
// Browser  code
//#############################################################################
/**
 * Get Browser info for functions.
 * @return Returns a Browser object.
 * @type MQBrowser
 * @private
 */
function mqGetBrowserInfo()
{
    var browser             = new MQBrowser();
    browser.name            = browser.version = browser.os = "unknown";
    var userAgent           = window.navigator.userAgent.toLowerCase();
    var appname             = window.navigator.appName;
    var appVersion          = window.navigator.appVersion;
    var browserListArray    = new Array("firefox", "msie", "netscape", "opera", "safari");
    var osListArray         = new Array("linux", "mac", "windows", "x11");
    var browserListlength   = browserListArray.length;
    var strPosition         = "";
    for(var i = 0, n = browserListlength; i < n; i++)
    {   // get browser name and version
        strPosition = userAgent.indexOf(browserListArray[i]) + 1;
        if(strPosition > 0)
        {
            browser.name = browserListArray[i]; // browser name

            var versionPosition = strPosition + browser.name.length;
            var incr = ((browser.name == "safari") || (userAgent.charAt(versionPosition + 4) > 0 && userAgent.charAt(versionPosition + 4) < 9)) ? 5 : 3;
            browser.version     = userAgent.substring(versionPosition, versionPosition + incr); // browser version
        }
    }
    var osListArrayLength = osListArray.length;
    for(var j = 0, m = osListArrayLength; j < m; j++)
    {
        strPosition = userAgent.indexOf(osListArray[j]) + 1;
        if(strPosition > 0)
        {
            browser.os  = osListArray[j];
        }
    }

    if (appname == "Netscape")
        browser.appname = "ns";
    else if (appname == "Microsoft Internet Explorer")
        browser.appname = "ie";

    browser.appVersion = appVersion;
    browser.vMajor  = parseInt(browser.appVersion);
    browser.isNS    = (browser.appname =="ns" && browser.vMajor >= 4);
    browser.isNS4   = (browser.appname =="ns" && browser.vMajor == 4);
    browser.isNS6   = (browser.appname =="ns" && browser.vMajor == 5);
    browser.isIE    = (browser.appname =="ie" && browser.vMajor >= 4);
    browser.isIE4   = (browser.appVersion.indexOf ('MSIE 4')   >0);
    browser.isIE5   = (browser.appVersion.indexOf ('MSIE 5')   >0);
    browser.isDOM   = (document.createElement
                    && document.appendChild
                    && document.getElementsByTagName) ? true : false;

   browser.isSafari = (browser.name == "safari");
    if (userAgent.indexOf ("win") > - 1)
        browser.platform = "win";
    else if (userAgent.indexOf("mac") > -1)
        browser.platform = "mac";
    else
        browser.platform="other";

    return browser;

} //getBrowserInfo()

var mqBrowserInfo = mqGetBrowserInfo();


//#############################################################################
// Begin class MQObject
//#############################################################################
/**
 * Constructs a new MQObject object.
 * @class Base class for almost all objects in
 * the api.
 */
function MQObject(){
   /**
    * Value to represent the xml
    * @type Document
    *
    */
   var m_xmlDoc = null;
   /**
    * Returns the m_xmlDoc object.
    * @return The m_xmlDoc object.
    * @type Document
    *
    */
   this.getM_XmlDoc = function() {
      return m_xmlDoc;
   };
   /**
    * Sets the m_xmlDoc object.
    * @param {Document} xmlDoc the Document to set m_xmlDoc to.
    * @type void
    *
    */
   this.setM_XmlDoc = function(xmlDoc) {
      m_xmlDoc = xmlDoc;
   };
   /**
    * Value to represent the xpath of this object
    * @type Document
    *
    */
   var m_xpath = null;
   /**
    * Returns the m_xpath string.
    * @return The m_xpath string.
    * @type String
    *
    */
   this.getM_Xpath = function() {
      return m_xpath;
   };
   /**
    * Sets the m_xpath object.
    * @param {String} xpath the String m_xpath is set to.
    * @type void
    *
    */
   this.setM_Xpath = function(xpath) {
      m_xpath = xpath;
   };
}
   /**
    * Returns the text name of this class.
    * @return The text name of this class.
    * @type String
    */
   MQObject.prototype.getClassName = function(){
      return "MQObject";
   };
   /**
    * Returns the version of this class.
    * @return The version of this class.
    * @type int
    */
   MQObject.prototype.getObjectVersion = function(){
      return 0;
   };

   /**
    * Sets values in xml.
    * @param {String} strPropName the property to set
    * @param {String} strPropValue the value to set the property to
    * @type void
    *
    */
   MQObject.prototype.setProperty = function (strPropName, strPropValue) {
      var strXPathExpression;
      if (strPropName!==null) strXPathExpression= "/" + this.getM_Xpath() + "/" + strPropName;
      else strXPathExpression= "/" + this.getM_Xpath();
      var ndNewProp = mqSetNodeText(this.getM_XmlDoc(),strXPathExpression,strPropValue);
      if ( ndNewProp === null) {
         var ndNewPropParent = this.getM_XmlDoc().createElement(strPropName);
         var ndRoot = this.getM_XmlDoc().documentElement.appendChild(ndNewPropParent);
         ndNewProp = mqSetNodeText(this.getM_XmlDoc(),strXPathExpression,strPropValue);
      }
      return ndNewProp;
   };
   /**
     * Gets values from xml.
     * @param {String} strPropName the property to get
     * @return The property
     * @type String
     *
     */
   MQObject.prototype.getProperty = function (strPropName) {
      var strXPathExpression;
      if (strPropName!==null) strXPathExpression= "/" + this.getM_Xpath() + "/" + strPropName;
      else strXPathExpression= "/" + this.getM_Xpath();
      return mqGetXPathNodeText(this.getM_XmlDoc(),strXPathExpression);
   };
   /**
    * Create a copy of this object.
    * @return The new object which is a copy of this
    * @type MQObject
    */
   MQObject.prototype.copy = function () {
       var cp = new this.constructor;
       cp.loadXml(this.saveXml());
       return cp;
    };
   /**
    * Create a copy of this object where the outermost tag remains the same.
    * @return The new object which is a copy of this except the outermost tag.
    * @type MQObject
    * @private
    */
   MQObject.prototype.internalCopy = function (obj) {
      var strXml = "<" + obj.getM_Xpath();
      if(this.getObjectVersion() > 0){
         strXml = strXml + " Version=\"" + this.getObjectVersion() + "\"";
      }
      strXml = strXml + ">";
      var root = this.getM_XmlDoc().documentElement;
      var nodes = root.childNodes;
      var maxCount = nodes.length;
      for (var count=0;count<maxCount;count++){
         strXml = strXml + mqXmlToStr(nodes[count]);
      }
      strXml = strXml + "</" + obj.getM_Xpath() + ">";
      var cp = new this.constructor;
      cp.loadXml(strXml);
      return cp;
    };
// End class MQObject


//#############################################################################
// Begin Class MQPoint
// Inheirit from MQObject
MQPoint.prototype = new MQObject();
MQPoint.prototype.constructor = MQPoint;
//#############################################################################
/**
 * Constructs a new MQPoint object.
 *
 * @class Encapsulates X and Y coordinates.
 * @param {int/string} param1 OPTIONAL: Depending on the absence of param2.
 * If param2 exists then param1 is initial x (int - default is 0) otherwise
 * param1 is xpath (string - default is "Point").
 * @param {int} param2 OPTIONAL: initial y (default is 0).
 * @extends MQObject
 */
function MQPoint(param1, param2) {
   MQObject.call(this);
   /**
    * Value to represent the x value
    * @type int
    */
   this.x = 0;
   /**
    * Value to represent the y value
    * @type int
    */
   this.y = 0;

   // Set default path
   this.setM_Xpath("Point");

   if (arguments.length == 1){
      this.setM_Xpath(param1);
   }
   else if (arguments.length == 2){
      this.x = parseInt(param1);
      this.y = parseInt(param2);
      if (isNaN(this.x) || isNaN(this.y))
         throw new Error("MQPoint constructor called with invalid parameter");
   }
   else if (arguments.length > 2){
      throw new Error("MQPoint constructor called with "
         + arguments.length
         + " arguments, but it expects 0, 1, or 2 arguments");
   }

}

   /**
    * Returns the text name of this class.
    * @return The text name of this class.
    * @type String
    */
   MQPoint.prototype.getClassName = function(){
      return "MQPoint";
   };
   /**
    * Returns the version of this class.
    * @return The version of this class.
    * @type int
    */
   MQPoint.prototype.getObjectVersion = function(){
      return 0;
   };
   /**
    * Assigns the xml that relates to this object.
    * @param {String} strXml the xml to be assigned.
    * @type void
    *
    */
   MQPoint.prototype.loadXml = function (strXml) {
      if("undefined" !== typeof(mqutils)){
         this.setM_XmlDoc(mqCreateXMLDoc(strXml));
         this.x = this.getProperty("X");
         this.y = this.getProperty("Y");
      }
   };
   /**
    * Build an xml string that represents this object.
    * @return The xml string.
    * @type String
    *
    */
   MQPoint.prototype.saveXml = function () {
      return "<" + this.getM_Xpath() + "><X>" + this.x + "</X><Y>" + this.y + "</Y></" + this.getM_Xpath() + ">";
   };
   /**
     * Sets X.
     * @param {int} x the value to set X to
     * @type void
     */
   MQPoint.prototype.setX = function(x){
      this.x = parseInt(x);
      if (isNaN(this.x))
         throw new Error("MQPoint.setX called with invalid parameter");
   };
   /**
     * Gets X.
     * @return The X value
     * @type int
     */
   MQPoint.prototype.getX = function(){
      return this.x;
   };
   /**
     * Sets Y.
     * @param {int} y the value to set Y to
     * @type void
     */
   MQPoint.prototype.setY = function(y){
      this.y = parseInt(y);
      if (isNaN(this.y))
         throw new Error("MQPoint.setY called with invalid parameter");
   };
   /**
     * Gets Y.
     * @return The Y value
     * @type int
     */
   MQPoint.prototype.getY = function(){
      return this.y;
   };
   /**
     * Sets the horizontal and vertical coordinates to the values passed in.
     * @param {int} x the value to set X to
     * @param {int} y the value to set Y to
     * @type void
     */
   MQPoint.prototype.setXY = function(x, y){
      this.x = parseInt(x);
      this.y = parseInt(y);
      if (isNaN(this.x) || isNaN(this.y))
         throw new Error("MQPoint.setXY called with invalid parameter");
   };
   /**
   * Returns a true if both the X and Y values are set
   * to a value other than the static "INVALID" value.
   * @return True if both the X and Y values are not
   * equal to the static "INVALID".
   * @type Boolean
   */
   MQPoint.prototype.valid = function(){
      if("undefined" !== typeof(mqutils)){
         return ( Math.abs(this.x != MQCONSTANT.MQPOINT_INVALID) &&
         Math.abs(this.y != MQCONSTANT.MQPOINT_INVALID));
      }
      return false;
   };
   /**
   * Determines whether or not two points are equal. Two instances
   * of Point are equal if the values of their x and y member
   * fields, representing their position in the coordinate space,
   * are the same.
   * @param {MQPoint} pt an MQPoint object to be compared with this MQPoint
   * @return True if both the X and Y values are equal.
   * @type Boolean
   */
   MQPoint.prototype.equals = function(pt){
      if (pt){
         return (this.x === pt.x && this.y === pt.y);
      }
      return false;
   };

   /**
    * Returns a string representation of this <code>MQPoint</code>.
    * The format is <code>"x,y"</code>.
    *
    * @returns {string} a string representation of this <code>MQPoint</code>.
    */
   MQPoint.prototype.toString = function() {
      return this.x + "," + this.y;
   };
// End class MQPoint


//#############################################################################
// Begin Class MQLatLng
// Inheirit from MQObject
MQLatLng.prototype = new MQObject();
MQLatLng.prototype.constructor = MQLatLng;
//#############################################################################
/**
 * Constructs a new MQLatLng object.
 *
 * @class Contains a latitude/longitude pair.
 * @param {float/string} param1 OPTIONAL: Depending on the absence of param2.
 * If param2 exists then param1 is initial latitude (float - default is 0.0)
 * otherwise param1 is xpath (string - default is "LatLng").
 * @param {float} param2 OPTIONAL: initial longitude (default is 0.0).
 * @extends MQObject
 */
function MQLatLng (param1, param2) {
   MQObject.call(this);
   /**
    * Value to represent the latitude
    * @type float
    */
   this.lat = 0.0;
   /**
    * Value to represent the longitude
    * @type float
    */
   this.lng = 0.0;

   // Set default path
   this.setM_Xpath("LatLng");

   if (arguments.length == 1){
      this.setM_Xpath(param1);
   }
   else if (arguments.length == 2){
      this.lat = parseFloat(param1);
      this.lng = parseFloat(param2);
      if (isNaN(this.lat) || isNaN(this.lng))
         throw new Error("MQLatLng constructor called with invalid parameter");
   }
   else if (arguments.length > 2){
      throw new Error("MQLatLng constructor called with "
         + arguments.length
         + " arguments, but it expects 0, 1, or 2 arguments.");
   }

}
   /**
    * Returns the text name of this class.
    * @return The text name of this class.
    * @type String
    */
   MQLatLng.prototype.getClassName = function(){
      return "MQLatLng";
   };
   /**
    * Returns the version of this class.
    * @return The version of this class.
    * @type int
    */
   MQLatLng.prototype.getObjectVersion = function(){
      return 0;
   };
   /**
    * Assigns the xml that relates to this object.
    * @param {String} strXml the xml to be assigned.
    * @type void
    *
    */
   MQLatLng.prototype.loadXml = function (strXml) {
      if("undefined" !== typeof(mqutils)){
         this.setM_XmlDoc(mqCreateXMLDoc(strXml));
         this.lat = this.getProperty("Lat");
         this.lng = this.getProperty("Lng");
      }
   };
   /**
    * Build an xml string that represents this object.
    * @return The xml string.
    * @type String
    *
    */
   MQLatLng.prototype.saveXml = function () {
      return "<" + this.getM_Xpath() + "><Lat>" + this.lat + "</Lat><Lng>" + this.lng + "</Lng></" + this.getM_Xpath() + ">";
   };
   /**
     * Sets the latitude value.
     * @param {float} fLatitude the value to set lat to
     * @type void
     */
   MQLatLng.prototype.setLatitude = function(fLatitude){
      this.lat = parseFloat(fLatitude);
      if (isNaN(this.lat))
         throw new Error("MQLatLng.setLatitude called with invalid parameter");
   };
   /**
     * Returns the latitude value.
     * @return the latitude value.
     * @type float
     */
   MQLatLng.prototype.getLatitude = function(){
      return this.lat;
   };
   /**
     * Sets the longitude value.
     * @param {float} fLongitude the value to set lng to
     * @type void
     */
   MQLatLng.prototype.setLongitude = function(fLongitude){
      this.lng = parseFloat(fLongitude);
      if (isNaN(this.lng))
         throw new Error("MQLatLng.setLongitude called with invalid parameter");
   };
   /**
     * Returns the longitude value.
     * @return the longitude value.
     * @type float
     */
   MQLatLng.prototype.getLongitude = function(){
      return this.lng;
   };
   /**
     * Sets the latitude and longitude values.
     * @param {float} fLatitude the value to set lat to
     * @param {float} fLongitude the value to set lng to
     * @type void
     */
   MQLatLng.prototype.setLatLng = function(fLatitude, fLongitude){
      this.lat = parseFloat(fLatitude);
      this.lng = parseFloat(fLongitude);
      if (isNaN(this.lat) || isNaN(this.lng))
         throw new Error("MQLatLng.setLatLng called with invalid parameter");
   };
   /**
    * Calculates the distance between two lat/lng's in miles or meters. If LUnits not
    * provide then miles will be the default.
    * @param {MQLatLng} ll2   Second lat,lng position to calculate distance to.
    * @param {MQDistanceUnits} lUnits Units to calculate distance
    * @return Returns the distance in meters or miles.
    * @throws SomeException If the ll2 parameter is not the type MQLatLng
    * @throws SomeException If the lUnits parameter exists and is not the type MQDistanceUnits
    * @type double
    */
   MQLatLng.prototype.arcDistance = function( ll2, lUnits){
      if("undefined" !== typeof(mqutils)){
      // type checks
      if (ll2){
         if(ll2.getClassName()!=="MQLatLng"){
            alert("failure in arcDistance");
            throw "failure in arcDistance";
         }
      } else {
         alert("failure in arcDistance");
         throw "failure in arcDistance";
      }
      if(lUnits){
         mqIsClass("MQDistanceUnits", lUnits, false);
      } else {
         lUnits = new MQDistanceUnits(MQCONSTANT.MQDISTANCEUNITS_MILES);
      }

     // Check for same position
      if (this.getLatitude() == ll2.getLatitude() && this.getLongitude() == ll2.getLongitude()){
         return 0.0;
      }
      // Get the Lng difference.  Don't need to worry about
      //    crossing 180 since  cos(x) = cos(-x)
      var dLon = ll2.getLongitude() - this.getLongitude();
      var a = MQCONSTANT.MQLATLNG_RADIANS * (90.0 - this.getLatitude());
      var c = MQCONSTANT.MQLATLNG_RADIANS * (90.0 - ll2.getLatitude());
      var cosB = (Math.cos(a) * Math.cos(c)) + (Math.sin(a) * Math.sin(c) *
                     Math.cos(MQCONSTANT.MQLATLNG_RADIANS * (dLon)));
      var radius = (lUnits.getValue() === MQCONSTANT.MQDISTANCEUNITS_MILES) ? 3963.205 : 6378.160187;

      // Find angle subtended (with some bounds checking) in radians and
      //    multiply by earth radius to find the arc distance
      if (cosB < -1.0)
         return MQCONSTANT.PI * radius;
      else if (cosB >= 1.0)
         return 0;
      else
         return Math.acos(cosB) * radius;
      }
      return -1;
   };
   /**
   * Returns a true if both the latitude and longitude values are set
   * to a value other than the static "INVALID" value.
   * @return True if both the latitude and longitude values are not
   * equal to the static "INVALID".
   * @type Boolean
   */
   MQLatLng.prototype.valid = function(){
      if("undefined" !== typeof(mqutils)){
         return ( Math.abs(this.getLatitude()  - MQCONSTANT.MQLATLNG_INVALID) > MQCONSTANT.MQLATLNG_TOLERANCE &&
         Math.abs(this.getLongitude() - MQCONSTANT.MQLATLNG_INVALID) > MQCONSTANT.MQLATLNG_TOLERANCE );
      }
      return false;
   };
   /**
   * Determines whether or not two latlngs are equal. Two instances
   * of MQLatLng are equal if the values of their latitude and longitude member
   * fields, representing their position in the coordinate space,
   * are the same.
   * @param {MQLatLng} ll an MQLatLng object to be compared with this MQLatLng
   * @return True if both the latitude and longitude values are equal.
   * @type Boolean
   */
   MQLatLng.prototype.equals = function(ll){
      if (ll!==null){
         return (this.getLongitude() === ll.getLongitude() && this.getLatitude() === ll.getLatitude());
      }
      return false;
   };

   /**
    * Returns a string representation of this <code>MQLatLng</code>.
    * The format is <code>"latitude,longitude"</code>.
    *
    * @returns {string} a string representation of this <code>MQLatLng</code>.
    */
   MQLatLng.prototype.toString = function() {
      return this.lat + "," + this.lng;
   };
// End class MQLatLng


//crossbrowser wrapper to create an xml document object
//from a given string
/**
 * Crossbrowser wrapper to create an xml document object
 * from a given string
 * @param String strXML String to be converted into a Xml Document
 * @return Returns the converted String as a Document.
 * @type Document
 * @private
 */
function mqCreateXMLDoc(strXML) {
   var newDoc;

   if (document.implementation.createDocument){
      // Mozilla, create a new DOMParser
      var parser = new window.DOMParser();
      //escaping & for safari -start
      if(mqBrowserInfo.isSafari)
         strXML = strXML.replace( /&/g,'&amp;');
      //escaping & for safari -stop
      newDoc = parser.parseFromString(strXML, "text/xml");
   } else if (window.ActiveXObject){
      // Internet Explorer, create a new XML document using ActiveX
      // and use loadXML as a DOM parser.
      newDoc = new window.ActiveXObject("Microsoft.XMLDOM");
      newDoc.async="false";
      newDoc.loadXML(strXML);
   }

   return newDoc;
}


//crossbrowser wrapper to create an xml document object
//from a node
function mqCreateXMLDocFromNode(ndNewRoot) {
   var newDoc;
   ndNewRoot = ndNewRoot.documentElement;
   if (document.implementation.createDocument){
      var newDoc = document.implementation.createDocument("", "", null);
      try{newDoc.appendChild(newDoc.importNode(ndNewRoot,true))}catch(error){alert(error);alert(ndNewRoot.nodeName);};
   } else if (window.ActiveXObject){
      // Internet Explorer, create a new XML document using ActiveX
      // and use loadXML as a DOM parser.
      newDoc = new ActiveXObject("Microsoft.XMLDOM");
      newDoc.async="false";
      newDoc.loadXML(ndNewRoot.xml);
   }

   return newDoc;
}


// Begin class MQXMLDOC
function MQXMLDOC(){
   this.AUTOGEOCODECOVSWITCH = null;
   this.AUTOROUTECOVSWITCH = null;
   this.AUTOMAPCOVSWITCH = null;
   this.DBLAYERQUERY = null;
   this.LINEPRIMITIVE = null;
   this.POLYGONPRIMITIVE = null;
   this.RECTANGLEPRIMITIVE = null;
   this.ELLIPSEPRIMITIVE = null;
   this.TEXTPRIMITIVE = null;
   this.SYMBOLPRIMITIVE = null;
   this.LATLNG = null;
   this.POINT = null;
   this.POINTFEATURE = null;
   this.LINEFEATURE = null;
   this.POLYGONFEATURE = null;
   this.LOCATION = null;
   this.ADDRESS = null;
   this.SINGLELINEADDRESS = null;
   this.GEOADDRESS = null;
   this.GEOCODEOPTIONS = null;
   this.MANEUVER = null;
   this.ROUTEOPTIONS = null;
   this.ROUTERESULTS = null;
   this.ROUTEMATRIXRESULTS = null;
   this.RADIUSSEARCHCRITERIA = null;
   this.RECTSEARCHCRITERIA = null;
   this.POLYSEARCHCRITERIA = null;
   this.CORRIDORSEARCHCRITERIA = null;
   this.SIGN = null;
   this.TREKROUTE = null;
   this.INTCOLLECTION = null;
   this.DTCOLLECTION = null;
   this.LATLNGCOLLECTION = null;
   this.LOCATIONCOLLECTION = null;
   this.LOCATIONCOLLECTIONCOLLECTION = null;
   this.MANEUVERCOLLECTION = null;
   this.SIGNCOLLECTION = null;
   this.STRINGCOLLECTION = null;
   this.STRCOLCOLLECTION = null;
   this.FEATURECOLLECTION = null;
   this.PRIMITIVECOLLECTION = null;
   this.POINTCOLLECTION = null;
   this.TREKROUTECOLLECTION = null;
   this.FEATURESPECIFIERCOLLECTION = null;
   this.GEOCODEOPTIONSCOLLECTION = null;
   this.COVERAGESTYLE = null;
   this.RECORDSET = null;
   this.MAPSTATE = null;
   this.SESSION = null;
   this.SESSIONID = null;
   this.DTSTYLE = null;
   this.DTSTYLEEX = null;
   this.DTFEATURESTYLEEX = null;
   this.FEATURESPECIFIER = null;
   this.BESTFIT = null;
   this.BESTFITLL = null;
   this.CENTER = null;
   this.CENTERLATLNG = null;
   this.PAN = null;
   this.ZOOMIN = null;
   this.ZOOMOUT = null;
   this.ZOOMTO = null;
   this.ZOOMTORECT = null;
   this.ZOOMTORECTLATLNG = null;
   this.getAUTOGEOCODECOVSWITCH = function() {
      if (this.AUTOGEOCODECOVSWITCH===null)
         this.AUTOGEOCODECOVSWITCH = mqCreateXMLDoc("<AutoGeocodeCovSwitch/>");
      return this.AUTOGEOCODECOVSWITCH;
   }
   this.getAUTOROUTECOVSWITCH = function() {
      if (this.AUTOROUTECOVSWITCH===null)
         this.AUTOROUTECOVSWITCH = mqCreateXMLDoc("<AutoRouteCovSwitch><Name/><DataVendorCodeUsage>0</DataVendorCodeUsage><DataVendorCodes Count=\"0\"/></AutoRouteCovSwitch>");
      return this.AUTOROUTECOVSWITCH;
   }
   this.getAUTOMAPCOVSWITCH = function() {
      if (this.AUTOMAPCOVSWITCH===null)
         this.AUTOMAPCOVSWITCH = mqCreateXMLDoc("<AutoMapCovSwitch><Name/><Style/><DataVendorCodeUsage>0</DataVendorCodeUsage><DataVendorCodes Count=\"0\"/><ZoomLevels Count=\"14\"><Item>6000</Item><Item>12000</Item><Item>24000</Item><Item>48000</Item><Item>96000</Item><Item>192000</Item><Item>400000</Item><Item>800000</Item><Item>1600000</Item><Item>3000000</Item><Item>6000000</Item><Item>12000000</Item><Item>24000000</Item><Item>48000000</Item></ZoomLevels></AutoMapCovSwitch>");
      return this.AUTOMAPCOVSWITCH;
   }
   this.getDBLAYERQUERY = function() {
      if (this.DBLAYERQUERY===null)
         this.DBLAYERQUERY = mqCreateXMLDoc("<DBLayerQuery/>");
      return this.DBLAYERQUERY;
   }
   this.getLINEPRIMITIVE = function() {
      if (this.LINEPRIMITIVE===null)
         this.LINEPRIMITIVE = mqCreateXMLDoc("<LinePrimitive Version=\"2\"/>");
      return this.LINEPRIMITIVE;
   }
   this.getPOLYGONPRIMITIVE = function() {
      if (this.POLYGONPRIMITIVE===null)
         this.POLYGONPRIMITIVE = mqCreateXMLDoc("<PolygonPrimitive Version=\"2\"/>");
      return this.POLYGONPRIMITIVE;
   }
   this.getRECTANGLEPRIMITIVE = function() {
      if (this.RECTANGLEPRIMITIVE===null)
         this.RECTANGLEPRIMITIVE = mqCreateXMLDoc("<RectanglePrimitive Version=\"2\"/>");
      return this.RECTANGLEPRIMITIVE;
   }
   this.getELLIPSEPRIMITIVE = function() {
      if (this.ELLIPSEPRIMITIVE===null)
         this.ELLIPSEPRIMITIVE = mqCreateXMLDoc("<EllipsePrimitive Version=\"2\"/>");
      return this.ELLIPSEPRIMITIVE;
   }
   this.getTEXTPRIMITIVE = function() {
      if (this.TEXTPRIMITIVE===null)
         this.TEXTPRIMITIVE = mqCreateXMLDoc("<TextPrimitive Version=\"2\"/>");
      return this.TEXTPRIMITIVE;
   }
   this.getSYMBOLPRIMITIVE = function() {
      if (this.SYMBOLPRIMITIVE===null)
         this.SYMBOLPRIMITIVE = mqCreateXMLDoc("<SymbolPrimitive Version=\"2\"/>");
      return this.SYMBOLPRIMITIVE;
   }
   this.getLATLNG = function() {
      if (this.LATLNG===null)
         this.LATLNG = mqCreateXMLDoc("<LatLng/>");
      return this.LATLNG;
   }
   this.getPOINT = function() {
      if (this.POINT===null)
         this.POINT = mqCreateXMLDoc("<Point/>");
      return this.POINT;
   }
   this.getPOINTFEATURE = function() {
      if (this.POINTFEATURE===null)
         this.POINTFEATURE = mqCreateXMLDoc("<PointFeature/>");
      return this.POINTFEATURE;
   }
   this.getLINEFEATURE = function() {
      if (this.LINEFEATURE===null)
         this.LINEFEATURE = mqCreateXMLDoc("<LineFeature/>");
      return this.LINEFEATURE;
   }
   this.getPOLYGONFEATURE = function() {
      if (this.POLYGONFEATURE===null)
         this.POLYGONFEATURE = mqCreateXMLDoc("<PolygonFeature/>");
      return this.POLYGONFEATURE;
   }
   this.getLOCATION = function() {
      if (this.LOCATION===null)
         this.LOCATION = mqCreateXMLDoc("<Location/>");
      return this.LOCATION;
   }
   this.getADDRESS = function() {
      if (this.ADDRESS===null)
         this.ADDRESS = mqCreateXMLDoc("<Address/>");
      return this.ADDRESS;
   }
   this.getSINGLELINEADDRESS = function() {
      if (this.SINGLELINEADDRESS===null)
         this.SINGLELINEADDRESS = mqCreateXMLDoc("<SingleLineAddress/>");
      return this.SINGLELINEADDRESS;
   }
   this.getGEOADDRESS = function() {
      if (this.GEOADDRESS===null)
         this.GEOADDRESS = mqCreateXMLDoc("<GeoAddress/>");
      return this.GEOADDRESS;
   }
   this.getGEOCODEOPTIONS = function() {
      if (this.GEOCODEOPTIONS===null)
         this.GEOCODEOPTIONS = mqCreateXMLDoc("<GeocodeOptions/>");
      return this.GEOCODEOPTIONS;
   }
   this.getMANEUVER = function() {
      if (this.MANEUVER===null)
         this.MANEUVER = mqCreateXMLDoc("<Maneuver Version=\"1\"><Narrative/><Streets Count=\"0\"/><TurnType>-1</TurnType><Distance>0.0</Distance><Time>-1</Time><Direction>0</Direction><ShapePoints Count=\"0\"/><GEFIDs Count=\"0\"/><Signs  Count=\"0\"/></Maneuver>");
      return this.MANEUVER;
   }
   this.getROUTEOPTIONS = function() {
      if (this.ROUTEOPTIONS===null)
         this.ROUTEOPTIONS = mqCreateXMLDoc("<RouteOptions Version=\"3\"><RouteType>0</RouteType><NarrativeType>1</NarrativeType><NarrativeDistanceUnitType>0</NarrativeDistanceUnitType><MaxShape>0</MaxShape><MaxGEFID>0</MaxGEFID><Language>English</Language><CoverageName>navt_r</CoverageName><CovSwitcher><Name></Name><DataVendorCodeUsage>0</DataVendorCodeUsage><DataVendorCodes Count=\"0\"/></CovSwitcher><AvoidAttributeList Count=\"0\"/><AvoidGefIdList Count=\"0\"/><AvoidAbsoluteGefIdList Count=\"0\"/><StateBoundaryDisplay>1</StateBoundaryDisplay><CountryBoundaryDisplay>1</CountryBoundaryDisplay></RouteOptions>");
      return this.ROUTEOPTIONS;
   }
   this.getROUTERESULTS = function() {
      if (this.ROUTERESULTS===null)
         this.ROUTERESULTS = mqCreateXMLDoc("<RouteResults Version=\"1\"><Locations Count=\"0\"/><CoverageName/><ResultMessages Count=\"0\"/><TrekRoutes Count=\"0\"/></RouteResults>");
      return this.ROUTERESULTS;
   }
   this.getROUTEMATRIXRESULTS = function() {
      if (this.ROUTEMATRIXRESULTS===null)
         this.ROUTEMATRIXRESULTS = mqCreateXMLDoc("<RouteMatrixResults/>");
      return this.ROUTEMATRIXRESULTS;
   }
   this.getRADIUSSEARCHCRITERIA = function() {
      if (this.RADIUSSEARCHCRITERIA===null)
         this.RADIUSSEARCHCRITERIA = mqCreateXMLDoc("<RadiusSearchCriteria/>");
      return this.RADIUSSEARCHCRITERIA;
   }
   this.getRECTSEARCHCRITERIA = function() {
      if (this.RECTSEARCHCRITERIA===null)
         this.RECTSEARCHCRITERIA = mqCreateXMLDoc("<RectSearchCriteria/>");
      return this.RECTSEARCHCRITERIA;
   }
   this.getPOLYSEARCHCRITERIA = function() {
      if (this.POLYSEARCHCRITERIA===null)
         this.POLYSEARCHCRITERIA = mqCreateXMLDoc("<PolySearchCriteria/>");
      return this.POLYSEARCHCRITERIA;
   }
   this.getCORRIDORSEARCHCRITERIA = function() {
      if (this.CORRIDORSEARCHCRITERIA===null)
         this.CORRIDORSEARCHCRITERIA = mqCreateXMLDoc("<CorridorSearchCriteria/>");
      return this.CORRIDORSEARCHCRITERIA;
   }
   this.getSIGN = function() {
      if (this.SIGN===null)
         this.SIGN = mqCreateXMLDoc("<Sign><Type>0</Type><Text></Text><ExtraText></ExtraText><Direction>0</Direction></Sign>");
      return this.SIGN;
   }
   this.getTREKROUTE = function() {
      if (this.TREKROUTE===null)
         this.TREKROUTE = mqCreateXMLDoc("<TrekRoute><Maneuvers Count=\"0\"/></TrekRoute>");
      return this.TREKROUTE;
   }
   this.getINTCOLLECTION = function() {
      if (this.INTCOLLECTION===null)
         this.INTCOLLECTION = mqCreateXMLDoc("<IntCollection Count=\"0\"/>");
      return this.INTCOLLECTION;
   }
   this.getDTCOLLECTION = function() {
      if (this.DTCOLLECTION===null)
         this.DTCOLLECTION = mqCreateXMLDoc("<DTCollection Version=\"1\" Count=\"0\"/>");
      return this.DTCOLLECTION;
   }
   this.getLATLNGCOLLECTION = function() {
      if (this.LATLNGCOLLECTION===null)
         this.LATLNGCOLLECTION = mqCreateXMLDoc("<LatLngCollection Version=\"1\" Count=\"0\"/>");
      return this.LATLNGCOLLECTION;
   }
   this.getLOCATIONCOLLECTION = function() {
      if (this.LOCATIONCOLLECTION===null)
         this.LOCATIONCOLLECTION = mqCreateXMLDoc("<LocationCollection Count=\"0\"/>");
      return this.LOCATIONCOLLECTION;
   }
   this.getLOCATIONCOLLECTIONCOLLECTION = function() {
      if (this.LOCATIONCOLLECTIONCOLLECTION===null)
         this.LOCATIONCOLLECTIONCOLLECTION = mqCreateXMLDoc("<LocationCollectionCollection Count=\"0\"/>");
      return this.LOCATIONCOLLECTIONCOLLECTION;
   }
   this.getMANEUVERCOLLECTION = function() {
      if (this.MANEUVERCOLLECTION===null)
         this.MANEUVERCOLLECTION = mqCreateXMLDoc("<ManeuverCollection Count=\"0\"/>");
      return this.MANEUVERCOLLECTION;
   }
   this.getSIGNCOLLECTION = function() {
      if (this.SIGNCOLLECTION===null)
         this.SIGNCOLLECTION = mqCreateXMLDoc("<SignCollection Count=\"0\"/>");
      return this.SIGNCOLLECTION;
   }
   this.getSTRINGCOLLECTION = function() {
      if (this.STRINGCOLLECTION===null)
         this.STRINGCOLLECTION = mqCreateXMLDoc("<StringCollection Count=\"0\"/>");
      return this.STRINGCOLLECTION;
   }
   this.getSTRCOLCOLLECTION = function() {
      if (this.STRCOLCOLLECTION===null)
         this.STRCOLCOLLECTION = mqCreateXMLDoc("<StrColCollectin/>");
      return this.STRCOLCOLLECTION;
   }
   this.getFEATURECOLLECTION = function() {
      if (this.FEATURECOLLECTION===null)
         this.FEATURECOLLECTION = mqCreateXMLDoc("<FeatureCollection Count=\"0\"/>");
      return this.FEATURECOLLECTION;
   }
   this.getPRIMITIVECOLLECTION = function() {
      if (this.PRIMITIVECOLLECTION===null)
         this.PRIMITIVECOLLECTION = mqCreateXMLDoc("<PrimitiveCollection Count=\"0\"/>");
      return this.PRIMITIVECOLLECTION;
   }
   this.getPOINTCOLLECTION = function() {
      if (this.POINTCOLLECTION===null)
         this.POINTCOLLECTION = mqCreateXMLDoc("<PointCollection Count=\"0\"/>");
      return this.POINTCOLLECTION;
   }
   this.getTREKROUTECOLLECTION = function() {
      if (this.TREKROUTECOLLECTION===null)
         this.TREKROUTECOLLECTION = mqCreateXMLDoc("<TrekRouteCollection Count=\"0\"/>");
      return this.TREKROUTECOLLECTION;
   }
   this.getFEATURESPECIFIERCOLLECTION = function() {
      if (this.FEATURESPECIFIERCOLLECTION===null)
         this.FEATURESPECIFIERCOLLECTION = mqCreateXMLDoc("<FeatureSpecifierCollection Count=\"0\"/>");
      return this.FEATURESPECIFIERCOLLECTION;
   }
   this.getGEOCODEOPTIONSCOLLECTION = function() {
      if (this.GEOCODEOPTIONSCOLLECTION===null)
         this.GEOCODEOPTIONSCOLLECTION = mqCreateXMLDoc("<GeocodeOptionsCollection Count=\"0\"/>");
      return this.GEOCODEOPTIONSCOLLECTION;
   }
   this.getCOVERAGESTYLE = function() {
      if (this.COVERAGESTYLE===null)
         this.COVERAGESTYLE = mqCreateXMLDoc("<CoverageStyle/>");
      return this.COVERAGESTYLE;
   }
   this.getRECORDSET = function() {
      if (this.RECORDSET===null)
         this.RECORDSET = mqCreateXMLDoc("<RecordSet/>");
      return this.RECORDSET;
   }
   this.getMAPSTATE = function() {
      if (this.MAPSTATE===null)
         this.MAPSTATE = mqCreateXMLDoc("<MapState/>");
      return this.MAPSTATE;
   }
   this.getSESSION = function() {
      if (this.SESSION===null)
         this.SESSION = mqCreateXMLDoc("<Session Count=\"0\"/>");
      return this.SESSION;
   }
   this.getSESSIONID = function() {
      if (this.SESSIONID===null)
         this.SESSIONID = mqCreateXMLDoc("<SessionID/>");
      return this.SESSIONID;
   }
   this.getDTSTYLE = function() {
      if (this.DTSTYLE===null)
         this.DTSTYLE = mqCreateXMLDoc("<DTStyle/>");
      return this.DTSTYLE;
   }
   this.getDTSTYLEEX = function() {
      if (this.DTSTYLEEX===null)
         this.DTSTYLEEX = mqCreateXMLDoc("<DTStyleEx/>");
      return this.DTSTYLEEX;
   }
   this.getDTFEATURESTYLEEX = function() {
      if (this.DTFEATURESTYLEEX===null)
         this.DTFEATURESTYLEEX = mqCreateXMLDoc("<DTFeatureStyleEx/>");
      return this.DTFEATURESTYLEEX;
   }
   this.getFEATURESPECIFIER = function() {
      if (this.FEATURESPECIFIER===null)
         this.FEATURESPECIFIER = mqCreateXMLDoc("<FeatureSpecifier/>");
      return this.FEATURESPECIFIER;
   }
   this.getBESTFIT = function() {
      if (this.BESTFIT===null)
         this.BESTFIT = mqCreateXMLDoc("<BestFit Version=\"2\"/>");
      return this.BESTFIT;
   }
   this.getBESTFITLL = function() {
      if (this.BESTFITLL===null)
         this.BESTFITLL = mqCreateXMLDoc("<BestFitLL Version=\"2\"/>");
      return this.BESTFITLL;
   }
   this.getCENTER = function() {
      if (this.CENTER===null)
         this.CENTER = mqCreateXMLDoc("<Center/>");
      return this.CENTER;
   }
   this.getCENTERLATLNG = function() {
      if (this.CENTERLATLNG===null)
         this.CENTERLATLNG = mqCreateXMLDoc("<CenterLatLng/>");
      return this.CENTERLATLNG;
   }
   this.getPAN = function() {
      if (this.PAN===null)
         this.PAN = mqCreateXMLDoc("<Pan/>");
      return this.PAN;
   }
   this.getZOOMIN = function() {
      if (this.ZOOMIN===null)
         this.ZOOMIN = mqCreateXMLDoc("<ZoomIn/>");
      return this.ZOOMIN;
   }
   this.getZOOMOUT = function() {
      if (this.ZOOMOUT===null)
         this.ZOOMOUT = mqCreateXMLDoc("<ZoomOut/>");
      return this.ZOOMOUT;
   }
   this.getZOOMTO = function() {
      if (this.ZOOMTO===null)
         this.ZOOMTO = mqCreateXMLDoc("<ZoomTo/>");
      return this.ZOOMTO;
   }
   this.getZOOMTORECT = function() {
      if (this.ZOOMTORECT===null)
         this.ZOOMTORECT = mqCreateXMLDoc("<ZoomToRect/>");
      return this.ZOOMTORECT;
   }
   this.getZOOMTORECTLATLNG = function() {
      if (this.ZOOMTORECTLATLNG===null)
         this.ZOOMTORECTLATLNG = mqCreateXMLDoc("<ZoomToRectLatLng/>");
      return this.ZOOMTORECTLATLNG;
   }
}
var MQXML = new MQXMLDOC();
// End class MQXMLDOC



// Begin class MQObjectCollection
/* Inheirit from MQObject */
MQObjectCollection.prototype = new MQObject();
MQObjectCollection.prototype.constructor = MQObjectCollection;
 /**
 * Constructs a new MQObjectCollection object.
 * @class Base class for collections.  Takes care of basic functionality
 * @param {int} max The initial size of the collection array
 * @param {String} strMQObjectType The type of MQObject descedent to check for
 * @extends MQObject
 */
function MQObjectCollection(max) {
   MQObject.call(this);
   /**
    * Value to represent collection
    * @type Array
    *
    */
   var m_items = new Array();
   /**
    * Accessor method for m_items
    * @return The Array of m_items
    * @type Array
    *
    */
   this.getM_Items = function(){
      return m_items;
   };
   /**
    * Value to represent maximum number of items
    * @type int
    *
    */
   var m_maxItems = ( max !== null ) ? max : -1;
   /**
    * Value to represent className to check for
    * @type String
    *
    */
   var validClassName = "MQObject";
   /**
    * Accessor method for ValidClassName
    * @return Value of ValidClassName
    * @type String
    *
    */
   this.getValidClassName = function(){
      return validClassName;
   };
   /**
    * Accessor method for ValidClassName
    * @param {String} className Value of ValidClassName
    * @type void
    *
    */
   this.setValidClassName = function(className){
      validClassName = className;
   };
   /**
     * Adds this object to the array if it has not reached the maximum size.
     * Type Checking is left to the descendent class.
     * @return The new number of items in the array or nothing if it is unsuccessful
     * @type int
     *
     */
   this.add = function(obj){
      if(this.isValidObject(obj)){
         if (m_maxItems !== -1 && m_items.length === max) return;
         m_items.push(obj);
         return m_items.length;
      }
      return;
   };
   /**
     * Get the maximum size.
     * @return The size of the array
     * @type int
     *
     */
   this.getSize = function () {
      return m_items.length;
   };
   /**
     * Get the item at postion i
     * @return The object
     * @param {int} i The position in the array from which to pull the object
     * @type Object
     *
     */
   this.get = function(i){
      return m_items[i];
   };
   /**
     * Remove the item at postion iIndex
     * @return The object to be removed
     * @param {int} iIndex The position in the array from which to pull the object
     * @type MQObject
     *
     */
   this.remove = function (iIndex) {
      return m_items.splice(iIndex, 1);
   };
   /**
     * Remove all the items in the array
     * @type void
     *
     */
   this.removeAll = function () {
      m_items = null;
      m_items = new Array();
   };
   /**
     * Check if the array contains a specific object
     * @return True if the object is in the collection, false otherwise
     * @param {MQObject} item The object to search for
     * @type Boolean
     *
     */
   this.contains = function (item) {
      var size = this.getSize();
      for (var count = 0; count < size; count++) {
         if (m_items[count] === item) {
            return true;
         }
      }
      return false;
   };
   /**
     * Append a collection to this one
     * @param {MQObjectCollection} collection The collection to append to this one
     * @type void
     *
     */
   this.append = function(collection){
      if(this.getClassName()===collection.getClassName()){
         m_items = m_items.concat(collection.getM_Items());
      } else {
        alert("Invalid attempt to append " + this.getClassName() + " to " + collection.getClassName() + "!");
        throw "Invalid attempt to append " + this.getClassName() + " to " + collection.getClassName() + "!";
      }
   };
   /**
    * Replace an object at position i and return the old object.
    * @return True if valid, false otherwise
    * @type MQObject
    *
    */
   this.set = function(i, newO){
      var oldO = get(i);
      m_items[i] = newO;
      return oldO;
   };
   /**
     * Is this object a valid object for this collection.
     * @return True if valid, false otherwise
     * @type MQObject
     *
     */
   this.isValidObject = function(obj) {
      if(obj!==null){
         if(validClassName === "ALL"){
            return true;
         }else if(validClassName === "MQObject"){
            return true;
         }else if(validClassName === "String"){
            return true;
         } else if(validClassName === "int"){
            if (isNaN(obj)){
               return false;
            } else if (obj === Math.floor(obj)){
               return true;
            }
         } else if(obj.getClassName() === validClassName ){
            return true;
         }
      }
      return false;
   };
   /**
    * Value to represent the xpath of items in this collections
    * @type String
    *
    */
   var m_itemXpath = "Item";
   /**
    * Returns the m_itemXpath string.
    * @return The m_itemXpath string.
    * @type String
    *
    */
   this.getM_itemXpath = function() {
      return m_itemXpath;
   };
   /**
    * Sets the m_itemXpath string.
    * @param {String} itemXpath the String m_xpath is set to.
    * @type void
    *
    */
   this.setM_itemXpath = function(itemXpath) {
      m_itemXpath = itemXpath;
   };
   /**
    * Return the object, if it exists, with the id strId
    * @param {String} strId The id to check for.
    * @return The object if it exists.
    * @type Object
    *
    */
   this.getById = function (strId) {
      try{
         for (var count = 0; count < this.getSize(); count++) {
            if (m_items[count].getId() == strId) {
               return m_items[count];
            }
         }
      }catch(Error){
         // do nothing
         // if here then the objects in question don't support the getbyid method
      }
      return null;
   };
   /**
    * Remove an item by it's pointer.
    * @param {Object} item pointer to the item to remove.
    * @type void
    */
   this.removeItem = function (item) {
    for(var i = 0; i < m_items.length; i++)
    {
      if (m_items[i] == item)
      {
         this.remove(i);
         i = m_items.length;
      }
    }
   };
}
   /**
    * Returns the text name of this class.
    * @return The text name of this class.
    * @type String
    */
   MQObjectCollection.prototype.getClassName = function(){
      return "MQObjectCollection";
   };
   /**
    * Returns the version of this class.
    * @return The version of this class.
    * @type int
    */
   MQObjectCollection.prototype.getObjectVersion = function(){
      return 0;
   };
   /**
    * Wraps the get(i) method
     * @return The object
     * @param {int} i The position in the array from which to pull the object
     * @type Object
    */
   MQObjectCollection.prototype.getAt = function(i){
      return this.get(i);
   };

//************* BEGIN MQLatLngCollection ***************
// Begin class MQLatLngCollection
/* Inheirit from MQObjectCollection */
MQLatLngCollection.prototype = new MQObjectCollection(32678);
MQLatLngCollection.prototype.constructor = MQLatLngCollection;
/**
  * Constructs a new MQLatLngCollection object. The first MQLatLng in the collection
  * is expected to be a latlng but the rest are assumed to be deltas from the first.
  * When adding the latlngs or loading from xml the user will need to make the calculations.
  * @class Contains a collection of LatLng objects.
  * @extends MQObjectCollection
  * @see MQLatLng
  * @see MQDistanceUnits
  */
function MQLatLngCollection() {
   MQObjectCollection.call(this, 32678);
   this.setValidClassName("MQLatLng");
   this.setM_Xpath("LatLngCollection");
   this.setM_XmlDoc(mqCreateXMLDocFromNode(MQXML.getLATLNGCOLLECTION()));
}
   /**
    * Returns the text name of this class.
   * @return The text name of this class.
   * @type String
   */
   MQLatLngCollection.prototype.getClassName = function(){
      return "MQLatLngCollection";
   };
   /**
    * Returns the version of this class.
    * @return The version of this class.
    * @type int
    */
   MQLatLngCollection.prototype.getObjectVersion = function(){
      return 1;
   };
   /**
    * Assigns the xml that relates to this object.
    * @param {String} strXml the xml to be assigned.
    * @type void
    *
    */
   MQLatLngCollection.prototype.loadXml = function (strXml) {
      this.removeAll();
      var xmlDoc = mqCreateXMLDoc(strXml);
      this.setM_XmlDoc(xmlDoc);
      if (xmlDoc!==null){
				this._loadCollection(xmlDoc);
      }
   };
   /**
    * Assigns the xml that relates to this object using the create xml from node method.
    * @param {XmlNode} xmlNode the xml to be assigned.
    * @type void
    *
    */
   MQLatLngCollection.prototype.loadXmlFromNode = function (xmlNode) {
      this.removeAll();
      var xmlDoc = mqCreateXMLDocImportNode(xmlNode);
      this.setM_XmlDoc(xmlDoc);
      if (xmlDoc!==null){
				this._loadCollection(xmlDoc);
      }
   };
   /** hidden */
   MQLatLngCollection.prototype._loadCollection = function (xmlDoc) {
         var root = xmlDoc.documentElement;
         var nodes = root.childNodes;
         var maxCount = nodes.length;
         maxCount = (maxCount < 32678) ? maxCount : 32678;
		 var prevLat = 0;
		 var prevLng = 0;
		 var currentLat = 0;
		 var currentLng = 0;
         var latlng = null;
         // iterate through xml and create objects for collection
         if(this.getValidClassName()==="MQLatLng"){
            for (var count = 0;count < maxCount; count++){
					 if(count==0){
							if(nodes[count].firstChild!==null){
								 currentLat = nodes[count].firstChild.nodeValue/1000000;
							}
							count++;
							if(nodes[count].firstChild!==null){
								 currentLng = nodes[count].firstChild.nodeValue/1000000;
							}
					 } else {
							if(nodes[count].firstChild!==null){
								 currentLat = prevLat + (nodes[count].firstChild.nodeValue/1000000);
							}
							count++;
							if(nodes[count].firstChild!==null){
								 currentLng = prevLng + (nodes[count].firstChild.nodeValue/1000000);
							}
					 }
					 prevLat = currentLat;
					 prevLng = currentLng;
					 latlng = new MQLatLng(currentLat, currentLng);
               this.add(latlng);
         }
      }
   };
   /**
    * Build an xml string that represents this object.
    * @return The xml string.
    * @type String
    *
    */
   MQLatLngCollection.prototype.saveXml = function () {
		var strRet = "<" + this.getM_Xpath() + " Version=\"" + this.getObjectVersion() + "\" Count=\"" + this.getSize() + "\">";

		var size = parseInt(this.getSize());
		if(size >= 1){
			var nLat = nLng = nPrevLat = nPrevLng = nDeltaLat = nDeltaLng = 0;
			var latLng = null;
			for(var i = 0; i < size; i++){
				latLng = this.getAt(i);
				nLat = parseInt(latLng.getLatitude() * 1000000);
				nLng = parseInt(latLng.getLongitude() * 1000000);
				nDeltaLat = nLat - nPrevLat;
				nDeltaLng = nLng - nPrevLng;
				strRet += "<Lat>" + nDeltaLat + "</Lat>";
				strRet += "<Lng>" + nDeltaLng + "</Lng>";
				nPrevLat = nLat;
				nPrevLng = nLng;
			}
		}
		strRet = strRet + "</" + this.getM_Xpath() + ">";
		return strRet;
   };
// End class MQLatLngCollection

/******************************************************************************************
/**
 *
 * Reduce the points in the lat/lng collection.  All points that deviate
 * from a straight line by less than dDeviance are eliminated.
 *
 * @param dDeviance the deviance
 */
MQLatLngCollection.prototype.generalize = function(dDeviance) {

	var SOrigPoint = function()
	{
		this.pLL = null;            // Decimal position of the point.
		this.dSegmentLength = 0.0; // Length of segment that begins here.
		this.dPriorLength = 0.0;   // Accum. length of prior segments.
	}; // end class SOrigPoint

	var SDerivedPoint = function()
	{
		this.pLL = null;              // Decimal position of the point.
		this.ulOriginalPoint = 0;      // Number of original point.
	}; // end class SDerivedPoint


 /********** PJL: generalize main ************/
	mqllAnchor = null;
	var ulAnchor; //int
	var i; //int
	var dAccumLength = 0.0;
	var nPoints = this.getSize(); // int
	var pOrigPoints = new Array(nPoints); //new SOrigPoint[nPoints];
	var pDerivedPoints = new Array(nPoints);
	var nDerivedPoints = 0; //int

	if (nPoints < 2)
		 return;


	//store off our l/ls
	for (i = 0; i < nPoints; i++)
	{
		pOrigPoints[i] = new SOrigPoint();
		pDerivedPoints[i] = new SDerivedPoint();
		pOrigPoints[i].pLL = this.getAt(i);
	}

	//determine line segment lengths
	for (i = 0; i < nPoints - 1; i++)
	{
		pOrigPoints[i].dSegmentLength = pOrigPoints[i].pLL.arcDistance(pOrigPoints[(i+1)].pLL);
		if (i == 0)
			pOrigPoints[i].dPriorLength = 0.0;
		else
			pOrigPoints[i].dPriorLength = dAccumLength;
		dAccumLength += pOrigPoints[i].dSegmentLength;
	}

	//allocate space for our derived points
	mqllAnchor             = pOrigPoints[0].pLL;
	ulAnchor                = 0;
	pDerivedPoints[0].pLL  = mqllAnchor;
	pDerivedPoints[0].ulOriginalPoint = 0;
	nDerivedPoints = 1;

	for (i = 2; i < nPoints; i++)
	{
		 if (!this.isEverybodyWithinDeviation(pOrigPoints, ulAnchor, i, dDeviance))
		 {
				 mqllAnchor = pOrigPoints[(i - 1)].pLL;
				 ulAnchor = (i - 1);
				 pDerivedPoints[nDerivedPoints].pLL = mqllAnchor;
				 pDerivedPoints[nDerivedPoints].ulOriginalPoint = (i - 1);
				 nDerivedPoints++;
		 }
	}

	pDerivedPoints[nDerivedPoints].pLL = pOrigPoints[nPoints - 1].pLL;
	pDerivedPoints[nDerivedPoints].ulOriginalPoint = nPoints - 1;
	nDerivedPoints++;

	//iterate backwards through the derivedPoints list removing unused points from the collection
	var nPrev = nPoints; //int
	var nCount;
	for (nCount=(nDerivedPoints-1);nCount>=0;nCount--)
	{
	 if ((nPrev-1) != pDerivedPoints[nCount].ulOriginalPoint)
	 {
			for (var x=(nPrev-1);x>pDerivedPoints[nCount].ulOriginalPoint;x--)
			{
				 try
				 {
						 this.remove(x);
				 }
				 catch(e)
				 {
				 }
			}

			nPrev = pDerivedPoints[nCount].ulOriginalPoint;
	 }
	 else
	 {
			nPrev--;
	 }
	}

	pOrigPoints=null;
	pDerivedPoints=null;
};

MQLatLngCollection.prototype.isEverybodyWithinDeviation = function( pOrigPoints,
                                  ulOrigStartPoint,     //(IN) The first point
                                  ulOrigEndPoint,       //(IN) The last point
                                  dMaxDeviation)        //(IN) The max deviation permitted
{
	var dMilesPerLng=0.0;
	var dMaxDeviationSquared=0.0;

	var mqllStartPoint=null;
	var mqllEndPoint=null;
	var dLineLatMiles=0.0;
	var dLineLngMiles=0.0;
	var dLineLengthSquared=0.0;

	var i;

	var mqllPoint=null;
	var dPointLatMiles=0.0;
	var dPointLngMiles=0.0;
	var dPointLengthSquared=0.0;

	var dRatio=0.0;
	var dNumerator=0.0;
	var dDenominator=0.0;

	var dProjectionLengthSquared=0.0;
	var dDeviationLengthSquared=0.0;

	// Calculate miles/longitude.  Also calc. the square of the max deviation.

	dMilesPerLng = DistanceApproximation.getMilesPerLngDeg(pOrigPoints[ulOrigStartPoint].pLL.getLatitude());
	dMaxDeviationSquared = dMaxDeviation * dMaxDeviation;

	 // Build the vector, and it's length, between the start and end points.

	 mqllStartPoint = pOrigPoints[ulOrigStartPoint].pLL;
	 mqllEndPoint   = pOrigPoints[ulOrigEndPoint].pLL;
	 dLineLatMiles = (mqllEndPoint.getLatitude() - mqllStartPoint.getLatitude()) * DistanceApproximation.MILES_PER_LATITUDE;
	 dLineLngMiles = (mqllEndPoint.getLongitude() - mqllStartPoint.getLongitude()) * dMilesPerLng;
	 dLineLengthSquared = dLineLatMiles * dLineLatMiles + dLineLngMiles * dLineLngMiles;

	 // Test each intermediate point.

	for (i = ulOrigStartPoint + 1; i < ulOrigEndPoint; i++)
	{
		 // Build the vector, and it's length, between the start and test points.
		mqllPoint = pOrigPoints[i].pLL;
		dPointLatMiles = (mqllPoint.getLatitude() - mqllStartPoint.getLatitude()) * DistanceApproximation.MILES_PER_LATITUDE;;
		dPointLngMiles = (mqllPoint.getLongitude() - mqllStartPoint.getLongitude()) * dMilesPerLng;
		dPointLengthSquared = dPointLatMiles * dPointLatMiles + dPointLngMiles * dPointLngMiles;

		// To produce the projection of the length of imaginary line from the
		// origin to the test point onto the original line, generate it's ratio,
		// which is the dot product of the two vectors, divided by the dot product
		// of the line segment with itself.

		dNumerator   = dLineLatMiles * dPointLatMiles + dLineLngMiles * dPointLngMiles;
		dDenominator = dLineLatMiles * dLineLatMiles  + dLineLngMiles * dLineLngMiles;
		if (dDenominator == 0)
			 dRatio = 0;
		else
			 dRatio = dNumerator / dDenominator;

		dProjectionLengthSquared = dRatio * dRatio * dLineLengthSquared;

		dDeviationLengthSquared = dPointLengthSquared - dProjectionLengthSquared;

		if (dDeviationLengthSquared > dMaxDeviationSquared)
			return false;
	}
	return true;
};// END this.prototype.isEverybodyWithinDeviation

var DistanceApproximation = new function()
{
	this.m_testLat;
	this.m_testLng;
	this.m_mpd;
	this.m_milesPerLngDeg = new Array(69.170976, 69.160441, 69.128838, 69.076177, 69.002475,
																		 68.907753, 68.792041, 68.655373, 68.497792, 68.319345,
																		 68.120088, 67.900079, 67.659387, 67.398085, 67.116253,
																		 66.813976, 66.491346, 66.148462, 65.785428, 65.402355,
																		 64.999359, 64.576564, 64.134098, 63.672096, 63.190698,
																		 62.690052, 62.170310, 61.631630, 61.074176, 60.498118,
																		 59.903632, 59.290899, 58.660106, 58.011443, 57.345111,
																		 56.661310, 55.960250, 55.242144, 54.507211, 53.755675,
																		 52.987764, 52.203713, 51.403761, 50.588151, 49.757131,
																		 48.910956, 48.049882, 47.174172, 46.284093, 45.379915,
																		 44.461915, 43.530372, 42.585570, 41.627796, 40.657342,
																		 39.674504, 38.679582, 37.672877, 36.654698, 35.625354,
																		 34.585159, 33.534429, 32.473485, 31.402650, 30.322249,
																		 29.232613, 28.134073, 27.026963, 25.911621, 24.788387,
																		 23.657602, 22.519612, 21.374762, 20.223401, 19.065881,
																		 17.902554, 16.733774, 15.559897, 14.381280, 13.198283,
																		 12.011266, 10.820591, 9.626619, 8.429716, 7.230245,
																		 6.028572, 4.825062, 3.620083, 2.414002, 1.207185,
																			1.000000);

	this.MILES_PER_LATITUDE   = 69.170976;
	this.KILOMETERS_PER_MILE  = 1.609347;

	// Return the number of miles per degree of longitude
	this.getMilesPerLngDeg = function(lat)
	{
		 // needed to have parseInt to do rounding for array indexing
		 return (Math.abs(lat) <= 90.0) ? this.m_milesPerLngDeg[parseInt(Math.abs(lat) + 0.5)] : 69.170976;
	}
};

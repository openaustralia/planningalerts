

function previewMap(sAreaSize) {
    var sWarnings = "";

	//Check we have a valid postcode
	var sPostcode = document.getElementById('txtPostcode').value;
	
	if (sPostcode == ""){
		sWarnings = "Please enter a postcode";
	}else if (checkPostCode(sPostcode) ==false){
		sWarnings = "Sorry, the postcode you entered seems to be invalid";		
	}

	if (sWarnings == ""){
		//hide any exisitng warnings
		hideWarning();
		document.getElementById('txtPostcode').className = document.getElementById('txtPostcode').className.replace(" error","");
		
		//build url and open new window
    	var sUrl = 'preview.php?postcode=' + sPostcode + '&area_size=' + sAreaSize;
		document.open(sUrl,'name', 'width=515,height=490');
	}else{
		showWarning(sWarnings);
		document.getElementById('txtPostcode').className += " error";
		setFocus('txtPostcode');
	}
	    
}



function checkPostCode (toCheck) {

  // Permitted letters depend upon their position in the postcode.
  var alpha1 = "[abcdefghijklmnoprstuwyz]";                       // Character 1
  var alpha2 = "[abcdefghklmnopqrstuvwxy]";                       // Character 2
  var alpha3 = "[abcdefghjkstuw]";                                // Character 3
  var alpha4 = "[abehmnprvwxy]";                                  // Character 4
  var alpha5 = "[abdefghjlnpqrstuwxyz]";                          // Character 5
  

  // Array holds the regular expressions for the valid postcodes
  var pcexp = new Array ();
  pcexp.push (new RegExp ("^(" + alpha1 + "{1}" + alpha2 + "?[0-9]{1,2})(\\s*)([0-9]{1}" + alpha5 + "{2})$","i"));
  pcexp.push (new RegExp ("^(" + alpha1 + "{1}[0-9]{1}" + alpha3 + "{1})(\\s*)([0-9]{1}" + alpha5 + "{2})$","i"));
  pcexp.push (new RegExp ("^(" + alpha1 + "{1}" + alpha2 + "?[0-9]{1}" + alpha4 +"{1})(\\s*)([0-9]{1}" + alpha5 + "{2})$","i"));
  pcexp.push (/^(GIR)(\s*)(0AA)$/i);
  pcexp.push (/^(bfpo)(\s*)([0-9]{1,4})$/i);
  pcexp.push (/^(bfpo)(\s*)(c\/o\s*[0-9]{1,3})$/i);

  // Load up the string to check
  var postCode = toCheck;

  var valid = false;
  
  // Check the string against the types of post codes
  for ( var i=0; i<pcexp.length; i++) {
    if (pcexp[i].test(postCode)) {
    
      // The post code is valid - split the post code into component parts
      pcexp[i].exec(postCode);
      
      // Copy it back into the original string, converting it to uppercase and
      // inserting a space between the inward and outward codes
      postCode = RegExp.$1.toUpperCase() + " " + RegExp.$3.toUpperCase();
      
      // If it is a BFPO c/o type postcode, tidy up the "c/o" part
      postCode = postCode.replace (/C\/O\s*/,"c/o ");
      
      // Load new postcode back into the form element
      valid = true;
      
      // Remember that we have found that the code is valid and break from loop
      break;
    }
  }
  
  // Return with either the reformatted valid postcode or the original invalid 
  // postcode
  if (valid) {return postCode;} else return false;
}

function showWarning (sWarnings) {

    var sWarningHtml = '';

	if(sWarnings.indexOf('\n') > 0){
        var aWarnings = sWarnings.split('\n');
        sWarningHtml += '<ul>'
	    for (var i=0;i<aWarnings.length -1;i++) {
	       if (aWarnings[i]!= ''){
    	       sWarningHtml += '<li>' + aWarnings[i] + '</li>';
    	   }
        }
        sWarningHtml += '</ul>'
	}else{
	   sWarningHtml = sWarnings;
	}
    var oWarning;
    oWarning = document.getElementById('divWarning');
    
    oWarning.innerHTML = sWarningHtml;
    window.scroll(0,0);    
    oWarning.style.display = 'block' 
  
}

function hideWarning(){
	oWarning = document.getElementById('divWarning');
	oWarning.innerHTML = "";
	oWarning.style.display = "none";
}

function setFocus (sID) {
    document.getElementById(sID).focus();
}


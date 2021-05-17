
mfnpObj = function(){

	var agent = navigator.userAgent.toLowerCase();

	if (Number(agent.indexOf('iphone')) > -1) {
        this.browser = 'IOS';
    } else if (Number(agent.indexOf('ipad')) > -1) {
        this.browser = 'IOS';
    } else if (Number(agent.indexOf('ipod')) > -1) {
		this.browser = 'IOS';
    } else if (Number(agent.indexOf('android')) > -1) {
        this.browser = 'ANDROID';
    } else if (Number(agent.indexOf('windows phone')) > -1) {
        this.browser = 'WINDOWSPHONE';
	} else {
		this.browser = 'NOT SUPPORT';
	}
	this.agent = agent; //추가된 부분
}

mfnpObj.prototype = {

	/* mfnpRequest.js에 추가 */
	executeAccessCheck: function(){
		switch(this.browser.toString()){
		case 'IOS':
			return "IOS";
			
		case 'ANDROID': 
			return "ANDROID";
			
		case 'WINDOWSPHONE':
			return "WINDOWS";
			
		default: 
			return "OTHER";
		}		
	}	,

	isNativeAccess: function(){
		if(this.browser == "IOS"){
			if(window.webkit) {
				if(navigator.userAgent.toLowerCase().indexOf('fxios') > -1){
					return "IOS";
				}else if(navigator.userAgent.toLowerCase().indexOf('crios') > -1){
					return "IOS";
				}
				return true;
			}
			else return "IOS";
		}else if(this.browser == "ANDROID"){
			if(window.mfinity) return true;
			else return "ANDROID";
		}else{
			return "WINDOW";
		}
	},
	
	executeCamera: function(callBack, userSpec){
		var callBack = encodeURIComponent(callBack);
		var userSpec = encodeURIComponent(userSpec);
		
		if(this.browser == "IOS"){
			window.webkit.messageHandlers.executeCamera.postMessage("callbackFunc="+callBack+"&userSpecific="+userSpec+"");
		}else if(this.browser == "ANDROID"){
			window.mfinity.executeCamera(callBack, userSpec);
		}
	},
	
	getImage: function(callBack, userSpec){
		var callBack = encodeURIComponent(callBack);
		var userSpec = encodeURIComponent(userSpec);
		
		if(this.browser == "IOS"){
			window.webkit.messageHandlers.getImage.postMessage("callbackFunc="+callBack+"&userSpecific="+userSpec+"");
		}else if(this.browser == "ANDROID"){
			window.mfinity.getImage(callBack, userSpec);
		}
	},
	
	executeFileUpload: function(callBack, userSpec, fileObject, request){
		var callBack = encodeURIComponent(callBack);
		var userSpec = encodeURIComponent(userSpec);
		var request = encodeURIComponent(request);
		
		if(this.browser == "IOS"){
			var fileJsonObject = encodeURIComponent('{"0" : "'+decodeURIComponent(fileObject)+'"}');
			window.webkit.messageHandlers.executeFileUpload.postMessage("callbackFunc="+callBack+"&userSpecific="+userSpec+"&fileList="+fileJsonObject+"&uploadPath="+request);
		}else if(this.browser == "ANDROID"){
			var fileJsonObject = encodeURIComponent('{"0" : "'+decodeURIComponent(fileObject)+'"}');
			window.mfinity.executeFileUpload(callBack, userSpec, fileJsonObject, request);
		}
	},
	
	setBackKeyEvent: function(backkeyMode){
		backkeyMode = encodeURIComponent(backkeyMode);

		switch(this.browser.toString()){
		case 'IOS':
			break;
		case 'ANDROID': 
			window.mfinity.setBackKeyEvent(backkeyMode);
			break;
		default: 
			break;
		}
	},
	
	executeBackKeyEvent: function(callBack, userSpec){
		callBack = encodeURIComponent(callBack);
		userSpec = encodeURIComponent(userSpec);

		switch(this.browser.toString()){
		case 'IOS':		
            break;
		case 'ANDROID': 
			window.mfinity.executeBackKeyEvent(callBack, userSpec);
			break;
		default: 
			break;
		}
	},
	
	executeExitWebBrowser: function(){
		switch(this.browser.toString()){
		case 'IOS':
                break;
		case 'ANDROID': 
			window.mfinity.executeExitWebBrowser();
			break;
		default: 
			break;
		}
	},
	
	executeNativeBrowser: function(callBack, userSpec, url){
		callBack = encodeURIComponent(callBack);
		userSpec = encodeURIComponent(userSpec);
        url = encodeURIComponent(url);

        switch(this.browser.toString()){
            case 'IOS':
            	var prop = "callbackFunc="+callBack+"&userSpecific="+userSpec+"&url="+url;
            	window.webkit.messageHandlers.executeNativeBrowser.postMessage(prop);
                break;
            case 'ANDROID':
                window.mfinity.executeNativeBrowser(callBack,userSpec,url);
                break;
            default:
                break;
        }
    },
    
    getDeviceInfo: function(callBack, userSpec){
    	var callBack = encodeURIComponent(callBack);
    	var userSpec = encodeURIComponent(userSpec);
    	
    	switch(this.browser.toString()){
    		case 'IOS':
    			window.webkit.messageHandlers.getDeviceSpec.postMessage("callbackFunc=" + callBack + "&userSpecific=" + userSpec + "");
    			break;
    		case 'ANDROID':
    			window.mfinity.getDeviceInfo(callBack, userSpec);
    			break;
    		default:
    			break;
    	}
    },
    
	getGpsLocation: function(callBack, userSpec){
		callBack = encodeURIComponent(callBack);
		userSpec = encodeURIComponent(userSpec);

		switch(this.browser.toString()){
		case 'IOS':
			window.webkit.messageHandlers.getGpsLocation.postMessage("callbackFunc=" + callBack + "&userSpecific=" + userSpec + "");
			break;
		case 'ANDROID': 
			window.mfinity.getGpsLocation(callBack, userSpec);
			break;
		default:
			break;
		}
	},
    
	windowClose: function(callBack, userSpec){
		callBack = encodeURIComponent(callBack);
		userSpec = encodeURIComponent(userSpec);
		switch(this.browser.toString()){
		case 'IOS':
			window.webkit.messageHandlers.windowClose.postMessage("callbackFunc=" + callBack + "&userSpecific=" + userSpec + "");
			break;
		case 'ANDROID': 
			window.mfinity.windowClose(callBack, userSpec);
			break;
		default:
			break;
		}
	},
	
	setPushCallback: function(returnFunc,functionName){
        returnFunc = encodeURIComponent(returnFunc);
        functionName = encodeURIComponent(functionName);
        switch(this.browser.toString()){
            case 'ANDROID':
                window.mfinity.setPushCallback(returnFunc,functionName);
                break;
            case 'IOS':
            	var prop = "callbackFunc=" + returnFunc + "&functionName=" + functionName + "";
    	        window.webkit.messageHandlers.setPushCallback.postMessage(prop);
                //window.location.href = "mfinity://setPushCallback?callbackFunc="+returnFunc+"&functionName="+functionName;
                break;
    		default:
    			break;
        }
    },
    
    getPushCallback: function(returnFunc,userSpecific){
        returnFunc = encodeURIComponent(returnFunc);
        userSpecific = encodeURIComponent(userSpecific);
        switch(this.browser.toString()){
            case 'ANDROID':
                window.mfinity.getPushCallback(returnFunc,userSpecific);
                break;
            case 'IOS':
            	var prop = "callbackFunc=" + returnFunc + "&userSpecific=" + userSpecific + "";
    	        window.webkit.messageHandlers.getPushCallback.postMessage(prop);
                //window.location.href = "mfinity://getPushCallback?callbackFunc="+returnFunc+"&userSpecific="+userSpecific;
                break;
    		default:
    			break;            
        }
    },
    
    executeImageCrop: function(callbackFunc, userSpecific, path){
    	callbackFunc = encodeURIComponent(callbackFunc);
    	userSpecific = encodeURIComponent(userSpecific);
    	path = encodeURIComponent(path);

    	switch(this.browser.toString()){
	    	case 'IOS':
		    	var prop = "callbackFunc=" + callbackFunc + "&userSpecific=" + userSpecific + "&path=" + path;
		    	       window.webkit.messageHandlers.executeImageCrop.postMessage(prop);
		    	break;
	    	case 'ANDROID': 
		    	window.mfinity.executeImageCrop(callbackFunc, userSpecific, path);
		    	break;
	    	default:
		    	break;
    	}
	},
	
	isPopupView: function(){
    	if(this.browser.toString() == 'IOS'){
    		if(window.opener){
    			return true;
    		}
    		return false;    		
    	}else if(this.browser.toString() == 'ANDROID'){
    		if(window.mfinity.windowClose){
    			return true;
    		}
    		return false;    		
    	}else if(this.browser.toString() == 'NOT SUPPORT'){
    		if(window.opener){
    			return true;
    		}
    		return false;
    	}
	}
};

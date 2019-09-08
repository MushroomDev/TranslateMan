document.addEventListener('DOMContentLoaded', function(event) {
    // safari.extension.dispatchMessage('Document Loaded!');

    var hotKey = 'Shift';
    var isSelectToTranslate = 0;
    var isDoubleClickToTranslate = 0;
    var lastx = 0;
    var lasty = 0;
    var showboxdiv;
    var isInTrainBox = 0;
    var isNeedShowBox = 0; //是否当前窗口发出的翻译请求
    //safari.extension.dispatchMessage('askForHotKey');

    // if (window.frames.length != parent.frames.length){
    // 	//在iframe中不显示
    // 	return;
    // }
    
    safari.self.addEventListener('message', function (Event) {
        if (Event.name == 'answerForHotKey') {
            hotKey = Event.message.hotKey || 'Shift';
        }else if(Event.name == 'answerForTranslate'){
        	//判断是否应该显示翻译窗
        	if (isNeedShowBox == 0) {
        		return;
        	}
        	isNeedShowBox = 0;

        	var transObject = Event.message;
        
            //alert(Event.message.text);
            if (showboxdiv) {
            	//关闭之前的翻译窗
            	//showboxdiv.style.opacity = 0;
            	showboxdiv.parentNode.removeChild(showboxdiv);
            	showboxdiv = null;
            }

            let box = createBoxTransDiv(transObject.type,transObject.result,transObject.sourcetext,transObject.pinyin,transObject.wordtype,'',lastx,lasty);

			//离开翻译弹窗
            box.addEventListener('mouseleave', function(){
    			if (showboxdiv) {
    				//transbox.style.opacity = 0;
        			//setTimeout(function(){
            			showboxdiv.parentNode.removeChild(showboxdiv);
        			//},100);
        			showboxdiv = null;
    			}
    			isInTrainBox = 0;
    		});

			//进入翻译弹窗
    		box.addEventListener('mouseenter', function(){
    			isInTrainBox = 1;

    		});

            showboxdiv = box;
            window.document.body.appendChild(box);
            box.show();
        }
    }, false);
    
    document.addEventListener('keyup', (event) => {
        if (event.key == hotKey) {
            let target = document.querySelector('a:hover');
            if (target) {
                let box = makeBoxElement(target);
                document.body.appendChild(box);
                box.show();
                //离开翻译弹窗
            	box.addEventListener('mouseleave', function(){
            		box.parentNode.removeChild(box);
    			});
            }
        }
    });

    var selecttext = '';
    var lastmouseup = 0;
    document.body.addEventListener('mouseup',function(event) {
        
        var curSelectTxt = selectText();
 
        var isdoubleclick = 0;
        if (lastmouseup == 0) {
          lastmouseup = getCutTime();
        }else{
          var curtime = getCutTime();

          if (curtime-lastmouseup<=500) {//500毫秒内为双击
            //双击选择
            isdoubleclick = 1;
            //alert('双击'+(curtime-lastmouseup));
          }else{
            //拖动选择
            //alert('拖动'+(curtime-lastmouseup));
          }
          lastmouseup = curtime;
        }

        if (curSelectTxt == '') {
        	//取消了选择 隐藏弹窗,必须不在翻译框中才可以
         	if (showboxdiv && isInTrainBox == 0) {
            	//关闭之前的翻译窗
            	//showboxdiv.style.opacity = 0;
            	showboxdiv.parentNode.removeChild(showboxdiv);
            	showboxdiv = null;
            }
          return;
        }

        if (selecttext == curSelectTxt && showboxdiv) { 
          //选择文字相同，并且弹窗正在显示
        }else{
          //判断是否是自己的弹窗容器
          let selectitem = window.getSelection().focusNode;
          if (selectitem) {
          	var itemid = selectitem.parentNode.id;
          	if (itemid == 'trainman') {
          		//自己容器的选择不选择
          		return;
          	}
          }

          selecttext = curSelectTxt;
          var e = event;
          var scrollX = document.documentElement.scrollLeft || document.body.scrollLeft;
          var scrollY = document.documentElement.scrollTop || document.body.scrollTop;
          var x = e.pageX || e.clientX + scrollX;
          var y = e.pageY || e.clientY + scrollY;
          //alert('x: ' + x + '\ny: ' + y);
          lastx = x;
          lasty = y;
          //当前窗口发出的翻译请求
          isNeedShowBox = 1;
          safari.extension.dispatchMessage("askForTranslate",{"text": selecttext,"type":isdoubleclick==1?"1":"0"});
        }
    },false);

    document.body.addEventListener('dblclick',function(event){
        //alert('双击了');
    
    },false);
});

//transtype 翻译类型,transresult 翻译结果,yuanwen 原文,pinyin 拼音,wordtype 词形,samemean 近义词,posx 坐标x,posy 坐标y
function createBoxTransDiv(transtype,transresult,yuanwen,pinyin,wordtype,samemean,posx,posy){

   let offset = 15;

   //容器
    let div = document.createElement('div');
    let width = 0;
    let height = 0;
    let showtext = '';
    let expandedBounding = null;

  	let frameposx = posx;

    if (transtype == 'Word') {//单词
    	width = 'auto';
    	height = 'auto';
    	showtext = yuanwen + '  ' +pinyin +'<br/>' + wordtype + ' ' + transresult +'<br/>';
    }else{//句子
    	showtext = transresult;
    	if (transresult.length>20) {
        	width = 300 + offset * 2;

        	height = 'auto';
    	}else{
    		width = 'auto';
    		height = 'auto';
    	}
    }
    if (document.body.clientWidth - posx <= 300) {
    	frameposx = posx - 300;
    }


    expandedBounding = {
        left: frameposx + 20 ,
        top: posy - offset ,
        width: width,
        height: height
        };


    div.innerHTML = '<p  style=“font-family:Arial,Verdana,Sans-serif;color:black;font-size:13px;” id="trainman" >'+showtext+'</p>';
    div.id = 'trainman';

    
    for (let key in expandedBounding) {
        expandedBounding[key] += 'px';
    }

    let computedStyle = window.getComputedStyle(div);

    let style = {
        'position': 'absolute',
        'z-index': 2147483647, // Literally the maximum number LOL..;
        'background-color': 'white',
        'font': computedStyle.font,
        // 'line-height': computedStyle.lineHeight,
        'color': 'black',
        'padding-left': '10px',
        'padding-top':  '10px',
        'padding-right': '10px',
        'padding-bottom':  '10px',
        'lineHeight': '100px',
        'box-sizing': 'border-box',
        'border-radius': '4px',
        'box-shadow': '0px 0px 0px 1px rgba(0 ,0, 0, 0.1), 0px 4px 8px rgba(0 ,0, 0, 0.25), 0px 8px 16px rgba(0 ,0, 0, 0.25)',
        'cursor': 'text',
        'transition': 'transform 0.1s ease-out, opacity 0.1s ease-in',
        'transform': 'scale(1)',
        'height':'auto'
    };
    style = Object.assign(style, expandedBounding);

    for (let key in style) {
        div.style.setProperty(key, style[key], 'important');
    }

    div.querySelectorAll('*').forEach( x => {
        x.style.cursor = 'text';
    });

    div.show = function(){
        setTimeout(function(){
            div.style.transform = 'scale(1.1)';
            setTimeout(function(){
                div.style.transform = 'scale(1)';
            },100);
        },50);
    };

    div.addEventListener('mouseleave', function(){
        div.style.opacity = 0;
        setTimeout(function(){
            div.parentNode.removeChild(div);
        },100);
    });

    return div;

}

function getCutTime(){
    return (new Date()).valueOf();
}

function selectText(){
    return window.getSelection().toString();
}

function makeBoxElement(element) {
    let offset = 8;

    let div = document.createElement('div');
    div.innerHTML = element.innerHTML;

    let rect = element.getBoundingClientRect();
    let expandedBounding = {
        left: rect.left - offset + window.scrollX,
        top: rect.top - offset + window.scrollY,
        width: rect.width + offset * 2,
        height: rect.height + offset * 2
    };
    for (let key in expandedBounding) {
        expandedBounding[key] += 'px';
    }

    let computedStyle = window.getComputedStyle(element);

    let style = {
        'position': 'absolute',
        'z-index': 2147483647, // Literally the maximum number LOL..;
        'background-color': 'white',
        'font': computedStyle.font,
        // 'line-height': computedStyle.lineHeight,
        'color': 'black',
        'padding-left': offset + parseInt(computedStyle.paddingLeft) + 'px',
        'padding-top': offset + parseInt(computedStyle.paddingTop) + 'px',
        'box-sizing': 'border-box',
        'border-radius': '4px',
        'box-shadow': '0px 0px 0px 1px rgba(0 ,0, 0, 0.1), 0px 4px 8px rgba(0 ,0, 0, 0.25), 0px 8px 16px rgba(0 ,0, 0, 0.25)',
        'cursor': 'text',
        'transition': 'transform 0.1s ease-out, opacity 0.1s ease-in',
        'transform': 'scale(1)'
    };
    style = Object.assign(style, expandedBounding);

    for (let key in style) {
        div.style.setProperty(key, style[key], 'important');
    }

    div.querySelectorAll('*').forEach( x => {
        x.style.cursor = 'text';
    });

    div.show = function(){
        setTimeout(function(){
            div.style.transform = 'scale(1.1)';
            setTimeout(function(){
                div.style.transform = 'scale(1)';
            },100);
        },50);
    };

    // div.addEventListener('mouseleave', function(){
    // 	if (div) {
    // 		div.style.opacity = 0;
    //     	setTimeout(function(){
    //         	div.parentNode.removeChild(div);
    //     	},100);
    // 	}
        
    // });

    return div;
}

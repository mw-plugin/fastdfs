function ftPostMin(method, args, callback){

    var req_data = {};
    req_data['name'] = 'fastdfs';
    req_data['func'] = method;
 
    if (typeof(args) != 'undefined' && args!=''){
        req_data['args'] = JSON.stringify(args);
    }

    $.post('/plugins/run', req_data, function(data) {
        if (!data.status){
            layer.msg(data.msg,{icon:0,time:2000,shade: [0.3, '#000']});
            return;
        }

        if(typeof(callback) == 'function'){
            callback(data);
        }
    },'json'); 
}

function ftPost(method, args, callback){
    var loadT = layer.msg('正在获取...', { icon: 16, time: 0, shade: 0.3 });
    ftPostMin(method,args,function(data){
        layer.close(loadT);
        if(typeof(callback) == 'function'){
            callback(data);
        } 
    });
}


function secToTime(s) {
    var t;
    if(s > -1){
        var hour = Math.floor(s/3600);
        var min = Math.floor(s/60) % 60;
        var sec = s % 60;
        if(hour < 10) {
            t = '0'+ hour + ":";
        } else {
            t = hour + ":";
        }

        if(min < 10){t += "0";}
        t += min + ":";
        if(sec < 10){t += "0";}
        t += sec.toFixed(2);
    }
    return t;
}


function ftEdit(){
    ftPost('ft_edit',{} , function(data){
        var rdata = $.parseJSON(data.data);
        var edit = '<p class="status">通用的手动编辑:</p>';
        var c = '';
        for (var i = 0; i < rdata.length; i++) {
            c+='<button class="btn btn-default btn-sm" onclick="onlineEditFile(0,\''+rdata[i]['path']+'\');">'+rdata[i]['name']+'</button>';
        }

        edit +='<div class="sfm-opt">'+c+'</div>'; 
        $(".soft-man-con").html(edit);
    });
    
}



window.onload = function() {
	CargarPerfil();
	CargarParcelas();
	CargarOrdenes();
	CargarMultas();
	CargarAsambleas();
	DivRegando();
};

 
function CargarParcelas(){
	var userpk=document.getElementById('userpk').value;
	var div_parc =document.getElementById('div_parc');
	var rpta = "";
	var xhr = new XMLHttpRequest();
	var cad = "/usuario/api_parc/?userpk="+userpk;
	xhr.open('GET',cad,true); 
	xhr.onreadystatechange = function(){
		if(xhr.readyState == 4 && xhr.status == 200){
			var json = xhr.response;
			if (json=="Err") {
				rpta="Algo salió mal en el servidor, intente nuevamente o verifique al administrador.";
			}else{
				var myObj = JSON.parse(json);
				for (var i in myObj) {
			        rpta+='<i><i class="fas fa-map-marked-alt"></i>      '+myObj[i]+'</i><br>'
			    }
			    div_parc.innerHTML=rpta;
			}
		}
	}
	xhr.send();
}


function CargarOrdenes(){
	var userpk=document.getElementById('userpk').value;
	var div_parc =document.getElementById('div_ord');
	var rpta = "";
	var xhr = new XMLHttpRequest();
	var cad = "/usuario/api_ord/?userpk="+userpk;
	xhr.open('GET',cad,true); 
	xhr.onreadystatechange = function(){
		if(xhr.readyState == 4 && xhr.status == 200){
			var json = xhr.response;
			if (json=="Err") {
				rpta='<i><i class="fas fa-money-check-alt"></i> Sin órdenes pendientes.</i><br>';
			}else{
				var myObj = JSON.parse(json);
				for (var i in myObj) {
			        rpta+='<i><i class="fas fa-money-check-alt"></i>        '+myObj[i]+'</i><br>';
			    }
			}
			div_parc.innerHTML=rpta;
		}
	}
	xhr.send();
}

 
function CargarMultas(){
	var userpk = document.getElementById('userpk').value;
	var alr_mul = document.getElementById('alr_mul');
	var div_mul = document.getElementById('div_mul');
	var rpta = "";
	var xhr = new XMLHttpRequest();
	var cad = "/usuario/api_mul/?userpk="+userpk;
	xhr.open('GET',cad,true); 
	xhr.onreadystatechange = function(){
		if(xhr.readyState == 4 && xhr.status == 200){
			var json = xhr.response;
			if (json=="Err") {
				alert("Algo salió mal en el servidor, intente nuevamente o verifique al administrador.");
			}else{
				var myObj = JSON.parse(json);		
			    alr_mul.innerHTML="+"+myObj['cant'];
			    div_mul.innerHTML='<i class="fas fa-dollar-sign"></i> Ud tiene '+myObj["cant"]+' multas.<br>';
			}
		}
	}
	xhr.send();
}


function  CargarPerfil(){
	var userpk=document.getElementById('userpk').value;
	var divprf = document.getElementById('idperfil');
	//var id_rutaf = document.getElementById('id_rutaf').value;
	var img = '<img src="/static/img/perfil.png" class="w-100 h-100 img-thumbnail rounded-circle">';
	var xhr = new XMLHttpRequest();
	var cad = "/usuario/api_perf/?userpk="+userpk;
	xhr.open('GET',cad,true); 
	xhr.onreadystatechange = function(){
		if(xhr.readyState == 4 && xhr.status == 200){
			var rpta = xhr.response;
			if (rpta=="Err") {
				alert("Algo salió mal en el servidor, intente nuevamente o verifique al administrador.");
			}else if (rpta=="Inv"){
				console.log("rpta: Inv -> No tiene foto.")
			}
			else{
				divprf.innerHTML='<img src="/media/'+rpta+'" class="w-100 h-100 img-thumbnail rounded-circle">';
			}
		}
	}
	xhr.send();
}


function CambContra(){
	var userpk = document.getElementById('userpk').value;
	var ncon = document.getElementById('ncon').value;
	var rncon = document.getElementById('rncon').value;
	if(ncon == rncon){
		var xhr = new XMLHttpRequest();
		var cad = "/usuario/api_cont/?userpk="+userpk+"&ncon="+ncon;
		xhr.open('GET',cad,true); 
		xhr.onreadystatechange = function(){
			if(xhr.readyState == 4 && xhr.status == 200){
				var rpta = xhr.response;
				if (rpta=="Ok") {
					alert("Se cambió su contraseña.");
				}else{
					alert("Error, consultar al administrador del sistema.");
				}
			}
		}
		xhr.send();
	}else{
		alert("> Deben coincidir las contraseñas");
	}
}

function EdiSexo(){
	var userpk = document.getElementById('userpk').value;
	var sx=document.getElementById('id_sexo').value;
	var sxv=document.getElementById('id_sxv');
	if (sx != "") {
		var xhr = new XMLHttpRequest();
		var cad = "/usuario/api_edi_sx/?userpk="+userpk+"&sx="+sx;
		xhr.open('GET',cad,true); 
		xhr.onreadystatechange = function(){
			if(xhr.readyState == 4 && xhr.status == 200){
				var rpta = xhr.response;
				if (rpta=="Ok") {
					sxv.value=sx;
				}else{
					alert("Error, consultar al administrador del sistema.");
				}
			}
		}
		xhr.send();
	}else{
		alert("Complete los campos");
	}
}

function EdiFechaN(){
	var userpk = document.getElementById('userpk').value;
	var fn=document.getElementById('id_fechan').value;
	var fnv=document.getElementById('id_fnv')
	if (fn != "") {
		var xhr = new XMLHttpRequest();
		var cad = "/usuario/api_edi_fn/?userpk="+userpk+"&fn="+fn;
		xhr.open('GET',cad,true); 
		xhr.onreadystatechange = function(){
			if(xhr.readyState == 4 && xhr.status == 200){
				var rpta = xhr.response;
				if (rpta=="Ok") {
					fnv.value=fn;
				}else{
					alert("Error, consultar al administrador del sistema.");
				}
			}
		}
		xhr.send();
	}else{
		alert("Complete los campos");
	}

}

function ApiOrdStd(pko,std){

	var ts = "tdstd"+pko;
	var tb = "tdbtn"+pko;

	var tdstd = document.getElementById(ts);
	var tdbtn = document.getElementById(tb);

	//alert(" > tdstd: "+tdstd.innerHTML+"   > tdbtn:"+tdbtn.innerHTML);

	var xhr = new XMLHttpRequest();
	var cad = "/usuario/api_orden/?ordpk="+pko+"&estado="+std;
	xhr.open('GET',cad,true); 
	xhr.onreadystatechange = function(){
		if(xhr.readyState == 4 && xhr.status == 200){
			var rpta = xhr.response;
			if (rpta=="Ok") {
				//alert("yeahhhh");
				if(std=="Entregada"){
					tdstd.innerHTML='<span class="badge badge-pill badge-light">Entregada</span>';
					tdbtn.innerHTML ='<a class="btn btn-sm btn-outline-warning" href="#" title="Iniciar riego." onclick="ApiOrdStd('+pko+',\'Iniciada\')"><i class="far fa-play-circle"></i> Iniciar</a>';
				}else if(std=="Iniciada"){
					tdstd.innerHTML='<span class="badge badge-pill badge-light">Iniciada</span>';
					tdbtn.innerHTML ='<a class="btn btn-sm btn-outline-secondary" href="#" title="Finalizar riego." onclick="ApiOrdStd('+pko+',\'Entregada\')"><i class="fas fa-arrow-left"></i> atrás</a>'+
					'<a class="btn btn-sm btn-outline-primary" href="#" title="Finalizar riego." onclick="ApiOrdStd('+pko+',\'Finalizada\')"><i class="fas fa-stopwatch"></i> Fin</a>';
				}else if(std=="Finalizada"){
					tdstd.innerHTML='<span class="badge badge-pill badge-light">Finalizada</span>';
					tdbtn.innerHTML ='<span class="badge badge-pill badge-secondary"><i class="fas fa-lock"></i></span>';
				}else{
					alert("Err: "+std);
				}
			}else{
				alert("Error, consultar al administrador del sistema.");
			}
		}
	}
	xhr.send();
}


function DivRegando(){
	var dvqr1= document.getElementById('dvqr');
	var xhr = new XMLHttpRequest();
	var cad = "/usuario/api_qr/?userpk=1";
	xhr.open('GET',cad,true); 
	var rpta ="Ok";
	xhr.onreadystatechange = function(){
		if(xhr.readyState == 4 && xhr.status == 200){
			var json = xhr.response;
			if (json=="Err") {
				rpta='<li><small>No están regando.</small></li>';
			}else{
				var myObj = JSON.parse(json);
				rpta ="";
				for (var i in myObj) {
			        rpta+='<li><small>'+myObj[i]+'</small></li>';
			    }
			}
			dvqr1.innerHTML=rpta;
		}
	}
	xhr.send();

}



function CargarAsambleas() {
	// body...
	var dva=document.getElementById("div_asamb");
	var xhr = new XMLHttpRequest();
	var cad = "/usuario/api_asmb/?userpk=1";
	xhr.open('GET',cad,true); 
	var rpta ="Ok";
	xhr.onreadystatechange = function(){
		if(xhr.readyState == 4 && xhr.status == 200){
			var json = xhr.response;
			if (json=="Err") {
				rpta='<i><i class="fas fa-users"></i> No hay reuniónes pendientes.</i><br>';
			}else{
				var myObj = JSON.parse(json);
				rpta ="";
				for (var i in myObj) {
			        rpta+='<i class="fas fa-users"></i>'+myObj[i]+'';
			    }
			}
			dva.innerHTML=rpta;
			dvasb.innerHTML=rpta;
		}
	}
	xhr.send();	
}


/*
function CargarGraficos(){


		

	var categories = []
	var data = []
	var fecha = ""
/*
	for (i=0; i<caudales.length; i++){
		var cad = ""+str(caudales.fecha.day)+"/"+str(caudales.fecha.month)+"/"+str(caudales.fecha.year)+""
		categories[i] = cad
	}
	
	for (i=0; i< caudales.length;i++) {
		data1[1]=caudales[i].nivel
	}
*/

/*
	var xhr = new XMLHttpRequest();
	var cad = "/usuario/api_graf1/?userpk=1";
	xhr.open('GET',cad,true); 
	var rpta ="Ok";
	xhr.onreadystatechange = function(){
		if(xhr.readyState == 4 && xhr.status == 200){
			var json = xhr.response;
			if (json=="Err") {
				console.log("  >> Err ");
			}else{
				var myObj = JSON.parse(json);
				cant = myObj[0];
				fecha = myObj[1];
				//alert("   fecha: "+fecha+"  cant: "+cant)
				for (var i=0; i<cant; i++) {
			        categories[i]=myObj[i+2]
			    }
			    for (var i=0; i<cant; i++) {
			        data[i]=myObj[i+50]
			        //alert(" >> data: "+data[i]+'  cat: '+categories[i]);
			    }
			}

		}
	}
	xhr.send();
	CargarC1();

}
function CargarC1() {
	// body...
alert(" Cargará ")
	Highcharts.chart('container1', {
    chart: {
        type: 'column',
        options3d: {
            enabled: true,
            alpha: 15,
            beta: 15,
            viewDistance: 25,
            depth: 40
        }
    },

    title: {
        text: 'Reporte de nivel de agua <br> '+fecha+'::'
    },

    xAxis: { 
    	categories, 
        labels: {
            skew3d: true,
            style: {
                fontSize: '16px'
            }
        }
    },

    yAxis: {
        allowDecimals: false,
        min: 0,
        title: {
            text: 'del  0   al   10',
            skew3d: true
        }
    },

    tooltip: {
        headerFormat: '<b>{point.key}</b><br>',
        pointFormat: '<span style="color:{series.color}">\u25CF</span> {series.name}: {point.y} / {point.stackTotal}'
    },

    plotOptions: {
        column: {
            stacking: 'normal',
            depth: 40
        }
    },

    series: [{name: 'Caudal',
        data,
        stack: 'male'
    }]
});

}

*/
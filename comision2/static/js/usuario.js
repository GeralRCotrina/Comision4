window.onload = function() {
	
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
				rpta="Algo salió mal en el servidor, intente nuevamente o verifique al administrador.";
			}else{
				var myObj = JSON.parse(json);
				for (var i in myObj) {
			        rpta+='<i><i class="fas fa-money-check-alt"></i>      '+myObj[i]+'</i><br>'
			    }
			    div_parc.innerHTML=rpta;
			}
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
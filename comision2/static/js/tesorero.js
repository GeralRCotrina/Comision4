

function EstMulta(pka){
	var id_std="id_estado"+pka;
	var id_tdstd="tdstd"+pka;
	var slc = document.getElementById(id_std).value;
	var tdstd = document.getElementById(id_tdstd);
	if (slc != "") {
		var xhr = new XMLHttpRequest();
		var cad = "/tesorero/t_std_mul/?pka="+pka+"&&std="+slc;
		xhr.open('GET',cad,true); 
		xhr.onreadystatechange = function(){
			if(xhr.readyState == 4 && xhr.status == 200){
				if (xhr.response=="Ok") {
					if (slc == "0") {
						tdstd.innerHTML='<span class="badge badge-pill badge-warning">Creada</span>';
					}else if (slc == "1") {
						tdstd.innerHTML='<span class="badge badge-pill badge-success">Pagada</span>';
					}else if (slc == "2") {
						tdstd.innerHTML='<span class="badge badge-pill badge-secondary">Anulada</span>';
					}else{
						alert("Err");
					}
				}else{
					alert("Algo salió mal en el servidor, intente nuevamente o verifique al administrador.")
				}
			}
		}
		xhr.send();
	}else{
		alert("Err");
	}
	
}

function EliMulta(pka){
	var id_tr="tr_"+pka;
	var tr = document.getElementById(id_tr);
	if(tr != null){
		var xhr = new XMLHttpRequest();
		var cad = "/tesorero/t_eli_mul/?pka="+pka;
		xhr.open('GET',cad,true); 
		xhr.onreadystatechange = function(){
			if(xhr.readyState == 4 && xhr.status == 200){
				if (xhr.response=="Ok") {
					tr.parentNode.removeChild(tr);
				}else{
					alert("Algo salió mal en el servidor, intente nuevamente o verifique al administrador.")
				}
			}
		}
		xhr.send();
	}else{
		alert("Algo salió mal, inteente nuevamente.")
	}
}



function EdiMulta(pka){
	var id_m = "nue_mon_"+pka;
	var id_c = "nue_con_"+pka;

	var id_tdmon = "tdmon"+pka;
	var id_tdcon = "tdcon"+pka;

	var n_monto = document.getElementById(id_m).value;
	var n_concepto = document.getElementById(id_c).value;

	var td_nom = document.getElementById(id_tdmon);
	var td_con = document.getElementById(id_tdcon);

	if (n_concepto != "" && n_monto != "") {
		var xhr = new XMLHttpRequest();
		var cad = "/tesorero/t_edi_mul/?pka="+pka+"&&monto="+n_monto+"&&concepto="+n_concepto;
		xhr.open('GET',cad,true); // sincrono o asincrono
		xhr.onreadystatechange = function(){
			if(xhr.readyState == 4 && xhr.status == 200){
				if (xhr.response=="Ok") {
					td_nom.innerHTML="S/. "+n_monto;
					td_con.innerHTML=n_concepto;
				}else{
					alert("Algo salió mal en el servidor, intente nuevamente o verifique al administrador.")
				}
			}
		}
		xhr.send();
	}else{
		alert("TIENE QUE COLOCAR AMBOS DATOS.");
	}
}



/*
 =================================ORDEN DE RIEGO ===============
*/



function EstMultaO(pka){
	var id_std="id_estado"+pka;
	var id_tdstd="tdstd"+pka;
	var slc = document.getElementById(id_std).value;
	var tdstd = document.getElementById(id_tdstd);
	if (slc != "") {
		var xhr = new XMLHttpRequest();
		var cad = "/tesorero/t_std_mulo/?pka="+pka+"&&std="+slc;
		xhr.open('GET',cad,true); 
		xhr.onreadystatechange = function(){
			if(xhr.readyState == 4 && xhr.status == 200){
				if (xhr.response=="Ok") {
					if (slc == "0") {
						tdstd.innerHTML='<span class="badge badge-pill badge-warning">Creada</span>';
					}else if (slc == "1") {
						tdstd.innerHTML='<span class="badge badge-pill badge-success">Pagada</span>';
					}else if (slc == "2") {
						tdstd.innerHTML='<span class="badge badge-pill badge-secondary">Anulada</span>';
					}else{
						alert("Err");
					}
				}else{
					alert("Algo salió mal en el servidor, intente nuevamente o verifique al administrador.")
				}
			}
		}
		xhr.send();
	}else{
		alert("Err");
	}
	
}

function EliMultaO(pka){
	var id_tr="tr_"+pka;
	var tr = document.getElementById(id_tr);
	if(tr != null){
		var xhr = new XMLHttpRequest();
		var cad = "/tesorero/t_eli_mulo/?pka="+pka;
		xhr.open('GET',cad,true); 
		xhr.onreadystatechange = function(){
			if(xhr.readyState == 4 && xhr.status == 200){
				if (xhr.response=="Ok") {
					tr.parentNode.removeChild(tr);
				}else{
					alert("Algo salió mal en el servidor, intente nuevamente o verifique al administrador.")
				}
			}
		}
		xhr.send();
	}else{
		alert("Algo salió mal, inteente nuevamente.")
	}
}



function EdiMultaO(pka){
	var id_m = "nue_mon_"+pka;
	var id_c = "nue_con_"+pka;

	var id_tdmon = "tdmon"+pka;
	var id_tdcon = "tdcon"+pka;

	var n_monto = document.getElementById(id_m).value;
	var n_concepto = document.getElementById(id_c).value;

	var td_nom = document.getElementById(id_tdmon);
	var td_con = document.getElementById(id_tdcon);

	if (n_concepto != "" && n_monto != "") {
		var xhr = new XMLHttpRequest();
		var cad = "/tesorero/t_edi_mulo/?pka="+pka+"&&monto="+n_monto+"&&concepto="+n_concepto;
		xhr.open('GET',cad,true); // sincrono o asincrono
		xhr.onreadystatechange = function(){
			if(xhr.readyState == 4 && xhr.status == 200){
				if (xhr.response=="Ok") {
					td_nom.innerHTML="S/. "+n_monto;
					td_con.innerHTML=n_concepto;
				}else{
					alert("Algo salió mal en el servidor, intente nuevamente o verifique al administrador.")
				}
			}
		}
		xhr.send();
	}else{
		alert("TIENE QUE COLOCAR AMBOS DATOS.");
	}
}



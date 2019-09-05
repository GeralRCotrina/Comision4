

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
					td_nom.innerHTML="S/: "+n_monto;
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





function GenHjaAsis(e,tipo_asmb){

	var xhr = new XMLHttpRequest();
	var cad = "/vocal/v_hasis_gen/?id_asmb="+e+"&&tipo_asmb="+tipo_asmb;

	xhr.open('GET',cad,true); // sincrono o asincrono
	xhr.onreadystatechange = function(){
		if(xhr.readyState == 4 && xhr.status == 200){
			alert("llegó");
			alert(" >"+xhr.response);
			
		}
	}
	xhr.send();

 }
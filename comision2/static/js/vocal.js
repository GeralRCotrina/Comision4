window.onload = function() {
	LlenarDiccJS1();
	LlenarDNIs();
};

var dnis = []
var dnisBK = []
var lleno = true;

var personas = []
var personaBK =[]
var primero = true;
var resultado = []
var pk_usuario = 0;

 
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


function SelctTipoAsamblea(){
	var divv =document.getElementById("LstCanales");
	var t_as =document.getElementById("tip_asamb").value;
	if(t_as == "Simple"){
		divv.classList.remove("d-none");
		divv.classList.remove("rotateOutDownRight");
		divv.classList.add("bounceInDown");
	}
	else{
		divv.classList.remove("bounceInDown");
		divv.classList.add("rotateOutDownRight");
	}
}


var cont_agnd = 99;
function AgregarAgnd(){
	var itm_agnd=document.getElementById("txt_itm");
	var Agnd = document.getElementById("Agnd");
	var cant_itm = document.getElementById("itm_cant");
	var txt_agnd = Agnd.innerHTML;
	cont_agnd +=1;
	Agnd.innerHTML= txt_agnd +'<p class="alert alert-success alert-dismissable">'+
						'<button type="button" class="close" data-dismiss="alert">×</button>'+
						'<strong>'+(cont_agnd-99)+'.- </strong> '+itm_agnd.value+
						'</p><input name="'+cont_agnd+'" type="hidden" value="'+(cont_agnd-99)+'.- '+itm_agnd.value+'">';
	cant_itm.value=cont_agnd;
	itm_agnd.value="";
}




function alEscribeJS1(){
	var dn = document.getElementById('valor1').value;

	if (dn.length == 8) {
		console.log(">>Podría ser un DNI.");
		LlenarDiccJS1();
		LimpiarJS1();
		Busqueda1(dn);
		MarcarAsis();
		InsertarTabla1();
	}
	else{
		LlenarDiccJS1();
		LimpiarJS1();
		Busqueda1(dn);
		InsertarTabla1();
	}
}

function MarcarAsis(){
	MrcAsist(pk_usuario,'Asistio');
}

function LlenarDiccJS1(){
	var tableReg = document.getElementById('dataTable1');
	var cellsOfRow="";
	var cont = 0;
	if(primero == true)
	{
		for (var i = 1; i < tableReg.rows.length; i++)
		{
			cont +=1;
			cellsOfRow = tableReg.rows[i].getElementsByTagName('td');
			personas.push({pk:cellsOfRow[0].innerHTML,usuario:cellsOfRow[1].innerHTML,
							dni:cellsOfRow[2].innerHTML,estado:cellsOfRow[3].innerHTML,hora:cellsOfRow[4].innerHTML});
		}
		personaBK=personas;
		primero = false;
	}
	else
		personas=personaBK;
}


function Busqueda1(txt){
	resultado = [];
	var cont0=0;
	var strr = "";
	for (var i = personas.length - 1; i >= 0; i--) {
		if(personas[i].usuario.toUpperCase().indexOf(txt.toUpperCase()) > -1 || personas[i].dni.toUpperCase().indexOf(txt.toUpperCase()) > -1)
		{
			cont0 += 1;
			resultado.push(personas[i]);
			pk_usuario = personas[i].pk
		}
		strr = strr+"-"+i;
	}
	$('#txt_tit').text(cont0+' resultados...');
}



function LimpiarJS1(){
	$('#cuerpo1').remove();
}


function InsertarTabla1() {
	var fila ='<tbody id="cuerpo1">';
	for (var i = resultado.length - 1; i >= 0; i--) 
	{
		fila +='<tr><td>'
		+resultado[i].pk+"</td><td>"
		+resultado[i].usuario+"</td><td>"
		+resultado[i].dni+'</td><td id="'+resultado[i].pk+'">'
		+resultado[i].estado+"</td><td>"
		+resultado[i].hora+"</td><td>"
		+'<div class="btn-group">'
			+'<button class="btn btn-outline-success" onclick="MrcAsist('+resultado[i].pk+',\'Asistio\')"><i class="fas fa-check"></i></button>'
			+'<button class="btn btn-outline-info" onclick="MrcAsist('+resultado[i].pk+',\'Tarde\')"><i class="far fa-clock"></i></button>'
			+'<button class="btn btn-outline-secondary" onclick="MrcAsist('+resultado[i].pk+',\'Falto\')"><i class="far fa-times-circle"></i></button>'
		+'</div></td></tr>';						
	}
	fila +="</tbody>";
	$('#dataTable1').append(fila);
}



function Encontro(){
	var dn = document.getElementById('valor1');
	dn.value="";
	resultado=personaBK;
	InsertarTabla1();
}




function Validar(e){
	var divc = document.getElementById("divconfirmar");
	if(e == "1"){
		divc.removeAttribute("hidden");
	}else if("2"){
		divc.setAttribute("hidden","hidden");		
	}else{
		alert("Err.")
	}
}






function LlenarDNIs(){
	var tableReg = document.getElementById('dataTable1');
	var cellsOfRow="";
	var cont = 0;
	if(lleno == true)
	{
		for (var i = 1; i < tableReg.rows.length; i++)
		{
			cont +=1;
			cellsOfRow = tableReg.rows[i].getElementsByTagName('td');
			dnis.push({pk:cellsOfRow[0].innerHTML,dni:cellsOfRow[2].innerHTML,estado:cellsOfRow[3].innerHTML});
		}
		dnisBK=dnis;
		lleno = false;
	}
	else
		dnis=dnisBK;
}


function Barcode(){
	var dn = document.getElementById('bar_dni').value;
	if (dn.length == 8) {

		//alert(" >tiene 8, ahora comparará :- "+dnis.length+" ->"+dnis[2].estado)
		for (var i = dnis.length - 1; i >= 0; i--) {
			if(dnis[i].dni.indexOf(dn) > -1)
			{
				MrcAsist(dnis[i].pk,TipMrc);
				document.getElementById('bar_dni').select();
			}
		}
	}
}


function MrcAsist(pkh,msj){
	var xhr = new XMLHttpRequest();
	var cad = "/vocal/v_hasis_est/?id_hje="+pkh+"&&std="+msj;
	var td_rpta ="Vacío";

	xhr.open('GET',cad,true); // sincrono o asincrono
	xhr.onreadystatechange = function(){
		if(xhr.readyState == 4 && xhr.status == 200){
			console.log("retornó successfull-1");
			var sp=document.getElementById(pkh);

			if( msj == 'Asistio'){
				td_rpta = '<span class="badge badge-pill badge-success">ASISTIÓ</span>';
			}
			else if(msj == 'Falto'){
				td_rpta = '<span class="badge badge-pill badge-secondary">FALTÓ</span>';
			}
			else if( msj == 'Tarde'){
				td_rpta ='<span class="badge badge-pill badge-info">TARDE</span>';
			}
			else{
				alert("ERR:     >>pkh:"+pkh+"     >> mdj: "+msj);
			}


			for (var i = personaBK.length - 1; i >= 0; i--) {
				if(personaBK[i].pk == pkh){
					personaBK[i].estado =td_rpta;
					sp.innerHTML = td_rpta;
				}
			}
		}
	}
	xhr.send();
}




function EliminarAsamb(pka){
	
	var xhr = new XMLHttpRequest();
	var cad = "../v_asamb_del/?pka="+pka;

	xhr.open('GET',cad,true); // sincrono o asincrono
	xhr.onreadystatechange = function(){
		if(xhr.readyState == 4 && xhr.status == 200){
			document.getElementById("palerta").innerHTML='<p class="alert alert-danger" ><STRONG>SE ELIMINÓ CON ÉXITO!!</STRONG>'+
															'<br><br>ya puede volver a crear su asamblea.</p>';
		}
	}
	xhr.send();
}

var TipMrc="Asistio";
function TipoMrc(){
	var d=document.getElementById("dic_slc");
	var i=document.getElementById("i_slc");

	d.classList.remove("btn-outline-success")
	d.classList.remove("btn-outline-secondary")
	d.classList.remove("btn-outline-info")

	i.classList.remove("fa-check")
	i.classList.remove("fa-clock")
	i.classList.remove("fa-times-circle")


	if(TipMrc == "Asistio"){
		d.classList.add("btn-outline-info")
		i.classList.add("fa-clock")
		TipMrc="Tarde";

	}else if(TipMrc == "Tarde"){
		d.classList.add("btn-outline-secondary")
		i.classList.add("fa-times-circle")
		TipMrc="Falto";
	}else{
		d.classList.add("btn-outline-success")
		i.classList.add("fa-check")
		TipMrc="Asistio";
	}
	document.getElementById('bar_dni').select();
}


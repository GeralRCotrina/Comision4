window.onload = function() {
	LlenarDicOrd();

};


function UrlJS(iOr,iRe,est){

	var idtdstd = "tdstd"+iOr;
	var tdstd = document.getElementById(idtdstd);


	var xhr = new XMLHttpRequest();
	var cad = "/canalero/c_orden_apr/?id_ord="+iOr+"&&id_rep="+iRe+"&&est="+est;

	xhr.open('GET',cad,true); // sincrono o asincrono
	xhr.onreadystatechange = function(){
		if(xhr.readyState == 4 && xhr.status == 200){

			if(est == "Rechazada"){
				tdstd.innerHTML = '<span class="badge badge-pill badge-danger"><i class="fas fa-ban"></i>  RECHAZADA</span>';
			}
			else if(est == "Aprobada"){
				tdstd.innerHTML = '<span class="badge badge-pill badge-success"><i class="fas fa-check"></i> APROBADA</span>';
			}
			else if(est == "Entregada"){
				tdstd.innerHTML = '<span class="badge badge-pill badge-secondary"><i class="fas fa-money-bill"></i>  ENTREGADA</span>';
			}
			else if(est == "Solicitada"){
				tdstd.innerHTML = '<span class="badge badge-pill badge-secondary badge-warning"><i class="fas fa-sign-in-alt"></i>  SOLICITADA</span>';
			}
			else{
				alert("Err: ");
			}
		}
	}
	xhr.send();
 }




var lleno = true;
var ordenes = [];
var ordenesBK=[];
var resultado = [];

function LlenarDicOrd(){
	var tableGen = document.getElementById('tableGen');
	var cellsOfRow="";
	var cont = 0;
	if(lleno == true)
	{
		for (var i = 0; i < tableGen.rows.length; i++)
		{
			cont +=1;
			cellsOfRow = tableGen.rows[i].getElementsByTagName('td');
			ordenes.push({recibo:cellsOfRow[0].innerHTML,canal:cellsOfRow[1].innerHTML,
							usuario:cellsOfRow[2].innerHTML,toma:cellsOfRow[3].innerHTML,parcela:cellsOfRow[4].innerHTML,
							fecha:cellsOfRow[5].innerHTML,hora:cellsOfRow[6].innerHTML,duracion:cellsOfRow[7].innerHTML,
							estado:cellsOfRow[8].innerHTML,acciones:cellsOfRow[9].innerHTML});
			//console.log(" ->  "+cellsOfRow[2].innerHTML)
		}
		ordenesBK=ordenes;
		lleno = false;
	}
	else
		ordenes=ordenesBK;
}

function BuscarOrden(){

	var txt_buscado = document.getElementById('txt_buscar').value;
	Buscar(txt_buscado);
	BorrarTabla();
	LlenarTabla();
}


function Buscar(txt){
	resultado = [];
	var cont0=0;
	for (var i = ordenes.length - 1; i >= 0; i--) {
		if(ordenes[i].usuario.toUpperCase().indexOf(txt.toUpperCase()) > -1)
		{
			cont0 += 1;
			resultado.push(ordenes[i]);
			pk_usuario = ordenes[i].pk
		}
	}
}

function BorrarTabla(){
	$('#tableGen').remove();
}

function LlenarTabla(){
	var fila ='<tbody id="tableGen">';
	for (var i = resultado.length - 1; i >= 0; i--) 
	{
		fila +='<tr><td>'
		+resultado[i].recibo+"</td><td>"
		+resultado[i].canal+'</td><td>'
		+resultado[i].usuario+"</td><td>"
		+resultado[i].toma+"</td><td>"
		+resultado[i].parcela+"</td><td>"
		+resultado[i].fecha+"</td><td>"
		+resultado[i].hora+"</td><td>"
		+resultado[i].duracion+"</td><td>"
		+resultado[i].estado+"</td><td>"
		+resultado[i].acciones+"</td></tr>";
	}
	fila +="</tbody>";
	$('#dataTable').append(fila);
}







var LstImprimir=[];
var LstImprimirBK=[];
var conta = 0;
var esta = true;

function AgrListImp(pko,nom){
	var esta = true;
	for (var i = LstImprimir.length - 1; i >= 0; i--) {
		if(LstImprimir[i] == pko){
			esta = false;
		}
	}
	if(esta){
		LstImprimir[conta]=pko;
		LstImprimir[conta+1]=nom;
		conta += 2;
		PintarModal();
	}else{
		alert("ya está en la lista!");
		esta=true;
	}	
}










function QuitarOrd(pko){
	for (var i = 0 ; i <=LstImprimir.length ; i++) {
		if(LstImprimir[i] == pko){
			delete LstImprimir[i];
			delete LstImprimir[i+1];
			conta-=2;
		}
		i+=1;
	}
	var c1 = 0;
	LstImprimirBK=[];
	for (var i = 0; i <=LstImprimir.length; i++){
		if(LstImprimir[i]){
			LstImprimirBK[c1]=LstImprimir[i];
			LstImprimirBK[c1+1]=LstImprimir[i+1];
			c1+=2;
		}else{
			console.log("no existe");
		}
		i+=1;
	}
	LstImprimir=[];
	LstImprimir=LstImprimirBK;

	PintarModal();
}



function PintarModal(){
// pinta el boton .......................
	var btn_impr = document.getElementById('btn_cnt_impr');
	btn_impr.innerHTML="<i class='fas fa-print'></i>="+ (LstImprimir.length/2);
// pinta el modal ......................
	var mdl = document.getElementById('mdl_imp');
	mdl.innerHTML="";

	for (var i = 0;i<LstImprimir.length; i++) {
		if(LstImprimir[i]){
			mdl.innerHTML+='<p class="ordenr alert-dismissable" style="border-style: dotted;">'
					+'<a href="#" class="close btn" data-dismiss="alert" onclick="QuitarOrd('+LstImprimir[i]+')">'
					+'<i class="fas fa-trash-alt text-danger mt-0" style="font-size:0.7em;"></i></a>'
					+'<strong>_'+LstImprimir[i]+'</strong>  Usuario:  '+LstImprimir[i+1]
					+'<br><i style="color: white;"> _____</i><i style="font-size: 0.7em; font-style: italic;">orden de riego ('+((i/2)+1)+')</i></p>';
			i+=1;
		}else{
			alert(" NO EXISTE .... i = "+i +"&& Lst[]="+ LstImprimir[i]);
		}
	}
	

// 	pintar boton ......
	var btn_imp=document.getElementById('btn_imp');
	btn_imp.innerHTML="";
	
	var jsn1 ='{';
	var primero = true;
	var c2 = 0;
	for (var i=0;i<LstImprimir.length; i++) {
		if(primero){
				jsn1+='"'+c2+'":'+LstImprimir[i];
				primero=false;
		}else if (LstImprimir[i]) {
				jsn1+=',"'+c2+'":'+LstImprimir[i];
		}
		i+=1;
		c2+=1;
	}
	jsn1 +='}';
	//alert("  jsn1 > "+jsn1);
	var url = document.getElementById('inpt_url').value;

	if(LstImprimir.length > 0){
		var jsn_btn= "<a href='"+url+jsn1+"&&tam="+(LstImprimir.length/2)+"' class='btn btn-primary'><!-- data-dismiss='modal'-->IMPRIMIR</a>";
	    btn_imp.innerHTML=jsn_btn;
	}else{
		 btn_imp.innerHTML="";
	}
}


function MrcDestajo(pkd,std){
	var idtdstd= "tdstd"+pkd;
	var tdstd = document.getElementById(idtdstd);
	var rpta="Err";
	if(std == 1){
		rpta='<span class="badge badge-primary">Revisado</span>';
	}else if(std == 2){
		rpta='<span class="badge badge-warning">Mal Hecho</span>';
	}else if(std == 3){
		rpta='<span class="badge badge-danger">No Hecho</span>';
	}else{
		spn.innerHTML="Err"
		rpta='';
	}
	tdstd.innerHTML=rpta;
	CmbStdDetDestajo(pkd,std);
}


function CmbStdDetDestajo(pkd,std){
	var urll = document.getElementById('id_url_dtdestajo').value;


	var xhr = new XMLHttpRequest();
	var cad = ""+urll+"?pkd="+pkd+"&&std="+std;

	xhr.open('GET',cad,true); // sincrono o asincrono
	xhr.onreadystatechange = function(){
		if(xhr.readyState == 4 && xhr.status == 200){
			console.log(" >> "+xhr.response);
		}
	}
	xhr.send();

}

		
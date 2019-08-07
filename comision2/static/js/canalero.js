window.onload = function() {
	LlenarDicOrd();

};


function UrlJS(iOr,iRe,est){

	var xhr = new XMLHttpRequest();
	var cad = "/canalero/c_orden_apr/?id_ord="+iOr+"&&id_rep="+iRe+"&&est="+est;

	xhr.open('GET',cad,true); // sincrono o asincrono
	xhr.onreadystatechange = function(){
		if(xhr.readyState == 4 && xhr.status == 200){
			var sp=document.getElementById("sp_"+iOr);
			sp.classList.remove("badge-success");
			sp.classList.remove("badge-danger");
			sp.classList.remove("badge-warning");
			if(est == "Rechazada")
			{
				sp.classList.add("badge-danger");
				sp.innerHTML = '<i class="fas fa-ban"></i>  RECHAZADA';
			}
			else if(est == "Aprobada")
			{
				sp.classList.add("badge-success");
				sp.innerHTML = '<i class="fas fa-check"></i> APROBADA';
			}
			else if(est == "Solicitada")
			{
				sp.classList.add("badge-warning");
				sp.innerHTML = '<i class="fas fa-sign-in-alt"></i>  SOLICITADA';
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

function AgrListImp(pko,nom){

	var pko_ico='PkImp_'+pko;
	var ImpIco = document.getElementById(pko_ico);
	var esta = true;

	if(LstImprimir.length>0){
		for (var i = LstImprimir.length - 1; i >= 0; i--) {
			if(LstImprimir[i]){
				if(LstImprimir[i].pko1 == pko){
					alert("ya esta en la cola de impresión");
					esta = false;
				}
			}
		}
	}
	if(esta){
		var pos = LstImprimir.length;
		var jsn=JSON.parse('{ "pko1":'+pko+', "nom":"'+nom+'"}');
	}


	LstImprimir[pos]=jsn;

	var btn_impr = document.getElementById('btn_cnt_impr');
	btn_impr.innerHTML="<i class='fas fa-print'></i>="+ (LstImprimir.length);
	
	PintarModal();
}


function PintarModal(){
	var mdl = document.getElementById('mdl_imp');
	mdl.innerHTML="";

	for (var i = LstImprimir.length - 1; i >= 0; i--) {
		if(LstImprimir[i]){
			mdl.innerHTML+='<p class="alert alert-success alert-dismissable">'
					+'<a href="#" class="close btn" data-dismiss="alert" onclick="QuitarOrd('+i+')">×</a>'
					+'<strong>'+LstImprimir[i].pko1+'</strong>   '+LstImprimir[i].nom+'</p>';
		}
	}
	BtnImprimirLista();
}

function QuitarOrd(i){
	delete LstImprimir[i];
	var cont1 =0;

	for (var i = LstImprimir.length - 1; i >= 0; i--) {
		if(LstImprimir[i]){
			LstImprimirBK[cont1]=LstImprimir[i];
			cont1 +=1;
		}
	}
	//alert(" > cont: "+cont1+" LstImprimirBK:"+LstImprimirBK.length+"    >LstImprimir: "+LstImprimir.length);
	LstImprimir=LstImprimirBK;
	//alert(" > cont: "+cont1+" LstImprimirBK:"+LstImprimirBK.length+"    >LstImprimir: "+LstImprimir.length);
	var btn_impr = document.getElementById('btn_cnt_impr');
	btn_impr.innerHTML="<i class='fas fa-print'></i>="+ (LstImprimir.length);
	al
	BtnImprimirLista();
}

function BtnImprimirLista(){
	var btn_imp=document.getElementById('btn_imp');
	var jsn1 ='{';
	var primero = true;
	for (var i = LstImprimir.length - 1; i >= 0; i--) {
		if (LstImprimir[i]) {
			if(primero){
				primero=false;
				jsn1+='"'+i+'":'+LstImprimir[i].pko1;
			}else{
				jsn1+=',"'+i+'":'+LstImprimir[i].pko1;
			}
			
		}
	}

	jsn1 +='}';
	var url = document.getElementById('inpt_url').value;

	if(LstImprimir.length > 0){
		var jsn_btn= "<a href='"+url+jsn1+"&&tam="+LstImprimir.length+"' class='btn btn-primary'><!-- data-dismiss='modal'-->IMPRIMIR</a>";
	    btn_imp.innerHTML=jsn_btn;
	}else{
		 btn_imp.innerHTML="";
	}

	    
}
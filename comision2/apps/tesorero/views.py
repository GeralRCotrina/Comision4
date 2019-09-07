from django.shortcuts import render, redirect
from django.contrib.auth.decorators import login_required, permission_required
from django.views.generic import View
from apps.inicio.models import *
import datetime
from django.db.models import Q
from django.http import HttpResponse

import pdfkit
from jinja2 import Environment, FileSystemLoader


# Create your views here.
@permission_required('inicio.es_tesorero')
def tesorero(request):
	return render(request, 'tesorero.html')



class Asmb(View):

	def get(self, request, *args, **kwargs):
		print("  >> GET")
		dicc = {}
		dicc['asambleas']=Asamblea.objects.all().order_by('-pk')
		return render(request,'asamblea/t_asamblea.html',dicc)

	def post(self, request, *args, **kwargs):
		print("  >> POST")
		return render(request,'asamblea/t_asamblea.html')


class AsmbMul(View):

	def get(self, request, *args, **kwargs):
		print("  >> ...GET   AsmbMul")
		pka=self.kwargs.get('pk')
		dicc = {}
		if Asamblea.objects.filter(pk=pka).exists():
			dicc['asamblea']=Asamblea.objects.get(pk=pka)
			asmb=Asamblea.objects.get(pk=pka)
			if HojaAsistencia.objects.filter(id_asamblea=asmb).exists():
				dicc['hoja_asistencia']=HojaAsistencia.objects.filter(id_asamblea=asmb).order_by('-estado')
		return render(request,'asamblea/t_asmb_mul.html',dicc)





from django.db.models import Q

class MultarAsistenciaTodas(View):

	def get(self, request, *args, **kwargs):
		print("  >> GET ->1")
		pko = self.request.GET.get('pko')
		dicc={}		
		dicc['pko']=pko
		dicc['fch']=datetime.datetime.now()
		return render(request,'multa/t_multa.html',dicc)

	def post(self, request, *args, **kwargs):
		print("  >> POST ->")
		pko = self.request.POST.get('pko')
		monto = self.request.POST.get('monto')
		concepto = self.request.POST.get('concepto')
		if HojaAsistencia.objects.filter(id_asamblea=pko).exists():
			las=HojaAsistencia.objects.filter(id_asamblea=pko)
			for l in las:
				if l.estado == "2" or l.estado == "3":
					rpta=CrearMultasAsist(l.pk,float(monto),concepto,1)
					if rpta:
						print( "  >>  "+str(l.pk)+" ]  >> Creó")
		dicc = {}
		dicc['hoja_multa']=HojaAsistencia.objects.filter(id_asamblea=pko)
		dicc['hoja_multas']=MultaAsistencia.objects.filter(id_hoja_asistencia__id_asamblea=pko).order_by("-id_hoja_asistencia__estado")
				
		return render(request,"multa/t_asmb_mul_lst.html",dicc)


class VerHojaDeMultas(View):

	def get(self, request, *args, **kwargs):
		print("  >> GET ->1")
		pko = self.request.GET.get('pko')
		dicc = {}

		if MultaAsistencia.objects.filter(id_hoja_asistencia__id_asamblea=pko).exists():
			dicc['hoja_multas']=MultaAsistencia.objects.filter(id_hoja_asistencia__id_asamblea=pko).order_by("-id_hoja_asistencia__estado")
		print("  >> pasó")
		return render(request,"multa/t_asmb_mul_lst.html",dicc)






class MultarAsistencia(View):

	def get(self, request, *args, **kwargs):
		pka = self.request.GET.get('pka')
		ha=HojaAsistencia.objects.get(pk=pka)
		dicc={}
		dicc['fch']=datetime.datetime.now()
		dicc['pka']=pka
		dicc['tpo']=ha.estado
		dicc['usr']=ha.id_auth_user.last_name.upper()+", "+ha.id_auth_user.first_name
		return render(request,'multa/mul_a_ts.html',dicc)

	def post(self, request, *args, **kwargs):
		monto = self.request.POST.get('monto')
		concepto = self.request.POST.get('concepto')
		pka = self.request.POST.get('pka')
		dicc={}		#print("  >> "+str(monto)+" >"+concepto+" > "+str(pka))

		if CrearMultasAsist(int(pka),float(monto),concepto,0):
			url = 'tesorero.html'
		else:
			dicc["Err"] = "No se pudo crear, intente nuevamente o consulte con el administrador del sistema." 
			url = 'multa/mul_a_ts.html'


		return render(request,url,dicc)




def CrearMultasAsist(pka,monto,concepto,gen):

	#Validamos datos
	rpta = False
	concept=":."
	if pka > 0:
		if monto > 0:
			if concepto != "":
				std=HojaAsistencia.objects.get(pk=pka).estado
				print("  >> std : "+str(std))
				if gen == 0:
					concept = concepto
				else:
					if concepto == "Tardanza o inasistencia.":
						if std == "2":
							concept = "Por tardanza a asamblea."
						elif std == "3":
							concept = "Por inasistencia a asamblea."
						else:
							concept = "-Err de concepto"
					else:
						concept=concepto
						
				#Validamos si no ha tiene
				if MultaAsistencia.objects.filter(id_hoja_asistencia=pka).exists():
					print("  >>YA TIENES MULTA")
					rpta =False
					#MultaAsistencia.objects.filter(id_hoja_asistencia=pka).delete()	
				else:
					if std != 2 and std != 3:
						nm=Multa(concepto=concept,monto=monto,fecha=datetime.datetime.now(),estado="0",tipo="0")
						nm.save()
						nma=MultaAsistencia(id_multa=nm,id_hoja_asistencia=HojaAsistencia.objects.get(pk=pka),tipo=std)
						nma.save()
						print("  >> Creada MA")
						rpta=True
					else:
						print("  >> Err en el estado")
						rpta=False
	return rpta


class EditarMulta(View):

	def get(self, request, *args, **kwargs):
		print(" >> EditarMulta")
		pka = self.request.GET.get('pka')
		mon = self.request.GET.get('monto')
		con = self.request.GET.get('concepto')
		rpta = 'Ok'
		if MultaAsistencia.objects.filter(pk=pka).exists():
			hma= MultaAsistencia.objects.get(pk=pka)
			if Multa.objects.filter(id_multa=hma.id_multa.pk).exists():
				Multa.objects.filter(id_multa=hma.id_multa.pk).update(monto=float(mon),concepto=con)
			else:
				rpta = 'Err'
		else:
			rpta = 'Err'
		return HttpResponse(rpta)




class EliminarMulta(View):

	def get(self, request, *args, **kwargs):
		print(" >> EliminarMulta")
		pka = self.request.GET.get('pka')
		rpta = 'Ok'
		if Multa.objects.filter(pk=int(float(pka))).exists():
			ml=Multa.objects.get(pk=int(float(pka)))
			MultaAsistencia.objects.filter(id_multa=ml).delete()
			Multa.objects.filter(pk=int(float(pka))).delete()
			print('  >> Ok')
		else:
			rpta = 'Err'
			print("  >> Err")
		return HttpResponse(rpta)


class ImprimirMulta(View):

	def get(self, request, *args, **kwargs):
		pka = self.request.GET.get('pka')
		rpta = 'Ok'
		dicc={}
		if pka != "":
			url='multa/t_imp_1.html'
			dicc['msj']="ók"
			#--------------------------------------------------pdf
			env = Environment(loader=FileSystemLoader("pdf", encoding = 'utf-8'))
			template = env.get_template("tesorero/impMul1.html")
			path_wkthmltopdf = b'C:\\Program Files\\wkhtmltopdf\\bin\\wkhtmltopdf.exe'
			config = pdfkit.configuration(wkhtmltopdf=path_wkthmltopdf)
			
			dicc['fch']=datetime.datetime.now()
			if MultaAsistencia.objects.filter(pk=pka).exists():
				dicc['multa']=MultaAsistencia.objects.get(pk=pka)

			html = template.render(dicc)
			f=open('pdf/tesorero/impMul2.html','w')
			f.write(html)
			f.close()
	 
			options = { 'page-size':'A4','margin-top':'0.2in','margin-right':'0.2in',
				'margin-bottom':'0.3in','margin-left':'0.2in'}

			pdfkit.from_file('pdf/tesorero/impMul2.html', 'static/pdfs/impMul3.pdf',options=options, configuration=config)

			dicc['url_pdf']='pdfs/impMul3.pdf'
			#--------------------------------------------------end pdf
			print("  >> finaló 1")
		else:
			print("  >> Err")
		return render(request,url,dicc)


class EstdoMulta(View):

	def get(self, request, *args, **kwargs):
		#print(" >> StdMulta")
		pka = self.request.GET.get('pka')
		std = self.request.GET.get('std')
		rpta = 'Ok'
		if MultaAsistencia.objects.filter(pk=pka).exists():
			hma= MultaAsistencia.objects.get(pk=pka)
			if Multa.objects.filter(id_multa=hma.id_multa.pk).exists():
				Multa.objects.filter(id_multa=hma.id_multa.pk).update(estado=std)
			else:
				rpta = 'Err'
				print("  >> Err1")
		else:
			rpta = 'Err'
			print("  >> Err2")
		return HttpResponse(rpta)


#===================================== ORDEN 

class EditarMultaO(View):

	def get(self, request, *args, **kwargs):
		print(" >> EditarMulta")
		pka = self.request.GET.get('pka')
		mon = self.request.GET.get('monto')
		con = self.request.GET.get('concepto')
		rpta = 'Ok'
		from apps.inicio.models import MultaOrden
		if MultaOrden.objects.filter(pk=pka).exists():
			hma= MultaOrden.objects.get(pk=pka)
			if Multa.objects.filter(id_multa=hma.id_multa.pk).exists():
				Multa.objects.filter(id_multa=hma.id_multa.pk).update(monto=float(mon),concepto=con)
			else:
				rpta = 'Err'
		else:
			rpta = 'Err'
		return HttpResponse(rpta)




class EliminarMultaO(View):

	def get(self, request, *args, **kwargs):
		print(" >> EliminarMulta")
		pka = self.request.GET.get('pka')
		rpta = 'Ok'
		from apps.inicio.models import MultaOrden
		if MultaOrden.objects.filter(pk=pka).exists():
			pko=MultaOrden.objects.get(pk=pka).pk
			MultaOrden.objects.filter(pk=pka).delete()
			Multa.objects.filter(pk=pko).delete()
		else:
			rpta = 'Err'
			print("  >> Err + "+str(pka))
		return HttpResponse(rpta)


class ImprimirMultaO(View):

	def get(self, request, *args, **kwargs):
		pka = self.request.GET.get('pka')
		rpta = 'Ok'
		dicc={}
		if pka != "":
			url='multa/t_imp_1.html'
			dicc['msj']="ók"
			#--------------------------------------------------pdf
			env = Environment(loader=FileSystemLoader("pdf", encoding = 'utf-8'))
			template = env.get_template("tesorero/impMulO1.html")
			path_wkthmltopdf = b'C:\\Program Files\\wkhtmltopdf\\bin\\wkhtmltopdf.exe'
			config = pdfkit.configuration(wkhtmltopdf=path_wkthmltopdf)
			
			dicc['fch']=datetime.datetime.now()
			from apps.inicio.models import MultaOrden
			if MultaOrden.objects.filter(pk=pka).exists():
				dicc['multa']=MultaOrden.objects.get(pk=pka)

			html = template.render(dicc)
			f=open('pdf/tesorero/impMulO2.html','w')
			f.write(html)
			f.close()
	 
			options = { 'page-size':'A4','margin-top':'0.2in','margin-right':'0.2in',
				'margin-bottom':'0.3in','margin-left':'0.2in'}

			pdfkit.from_file('pdf/tesorero/impMulO2.html', 'static/pdfs/impMulO3.pdf',options=options, configuration=config)

			dicc['url_pdf']='pdfs/impMulO3.pdf'
			#--------------------------------------------------end pdf
			print("  >> finaló 1")
		else:
			print("  >> Err")
		return render(request,url,dicc)


class EstdoMultaO(View):

	def get(self, request, *args, **kwargs):
		#print(" >> StdMulta")
		pka = self.request.GET.get('pka')
		std = self.request.GET.get('std')
		rpta = 'Ok'
		from apps.inicio.models import MultaOrden
		if MultaOrden.objects.filter(pk=pka).exists():
			hma= MultaOrden.objects.get(pk=pka)
			if Multa.objects.filter(id_multa=hma.id_multa.pk).exists():
				Multa.objects.filter(id_multa=hma.id_multa.pk).update(estado=std)
			else:
				rpta = 'Err'
				print("  >> Err1")
		else:
			rpta = 'Err'
			print("  >> Err2")
		return HttpResponse(rpta)

#===================================== END ORDEN


#-----------------------------------------------------reparto

class LstRepartos(View):

	def get(self, request, *args, **kwargs):
		#print(" >> StdMulta")
		print("  >> ok")

		dicc = {}
		dicc['lst_repartos']=Reparto.objects.all().order_by('-pk')

		return render(request,'reparto/t_lst_repartos.html',dicc)


class HjaMulReparto(View):

	def get(self, request, *args, **kwargs):
		print("  >> ok")		
		pkr = self.request.GET.get('pkr')

		dicc = {}
		from apps.inicio.models import MultaOrden
		if MultaOrden.objects.filter(id_orden__id_reparto=pkr).exists():
			dicc['hja_mul_reparto']=MultaOrden.objects.filter(id_orden__id_reparto=pkr)
		else:
			print("  >> Nooo hay multas de ordenes")

		return render(request,'reparto/hja_mul_reaprto.html',dicc)



class HjaOrdReparto(View):

	def get(self, request, *args, **kwargs):
		print("  >> ok-or")		
		pkr = self.request.GET.get('pkr')
		dicc = {}
		if OrdenRiego.objects.filter(id_reparto=pkr).exists():
			print("  >> Si hay multas de ordenes")
			dicc['hja_or_reparto']=OrdenRiego.objects.filter(id_reparto=pkr).order_by('-estado')
			dicc['reparto']=Reparto.objects.get(id_reparto=pkr)
		else:
			print("  >> Nooo hay multas de ordenes")
		return render(request,'reparto/hja_ord_reaprto.html',dicc)
		

class MultaOrden(View):

	def get(self, request, *args, **kwargs):
		print("  >> get")		
		pko = self.request.GET.get('pko')
		dicc = {}
		dicc['fch']=datetime.datetime.now()
		if OrdenRiego.objects.filter(id_orden_riego=pko).exists():
			print("  >> Si está ordene")
			dicc['orden_riego']=OrdenRiego.objects.get(id_orden_riego=pko)
		return render(request,'reparto/multa_ord.html',dicc)

	def post(self, request, *args, **kwargs):
		print("  >> post")		
		mon = self.request.POST.get('monto')
		pko = self.request.POST.get('pko')
		concept = self.request.POST.get('concepto')

		print("  >> monto: "+str(mon)+"  >> pko: "+str(pko)+"  >> con: "+str(concept))
		dicc={}
		#----------------creamos la multa
		if OrdenRiego.objects.filter(pk=int(pko)).exists():
			from apps.inicio.models import MultaOrden
			if MultaOrden.objects.filter(id_orden=pko).exists():
				dicc['rpta']="ya existe."
				print("  >> ya existe.")
			else:
				print("  >> creará.")
				mo=Multa(concepto=concept,fecha=datetime.datetime.now(),estado="0",tipo="1",monto=float(mon))
				mo.save()
				ordn=OrdenRiego.objects.get(pk=int(pko))			
				dml=MultaOrden(id_multa=mo,id_orden=ordn)
				dml.save()
				dicc['rpta']="creada con éxito!"


		return render(request,'reparto/multa_ord.html',dicc)




class EstadoOrden(View):
	def get(self, request, *args, **kwargs):
		pko = self.request.GET.get('pko')
		std = self.request.GET.get('std')
		rpta = "Err"
		if OrdenRiego.objects.filter(id_orden_riego=pko).exists():
			OrdenRiego.objects.filter(id_orden_riego=pko).update(estado=std)
			rpta = "Ok"
		else:
			rpta='Err'
		return HttpResponse(rpta)




# =================================== COMPROBANTE ============
from django.db.models import Q
class CompGenerar(View):
	def get(self, request, *args, **kwargs):
		pkr = self.request.GET.get('pkr')
		pkt = self.request.GET.get('pkt')
		rpta = "Err"
		print("  >> pko.."+pkr+"  >> pkt.."+pkt)

		if Reparto.objects.filter(pk=pkr).exists():
			hr_e=OrdenRiego.objects.filter(Q(id_reparto=pkr) & Q(estado="Entregada"))
			for ho in hr_e:
				print("  rpta: >"+CrearCompOrd(1,ho.pk))
		return redirect('/tesorero/t_cmp_lst/?pkr='+pkr)


def CrearCompOrd(pkt,pko):
	rpta ="Err"
	if Talonario.objects.filter(pk=pkt).exists():
		if CompOrden.objects.filter(id_orden=pko).exists():
			rpta="Inv"
		else:
			ordn=OrdenRiego.objects.get(pk=pko)
			tln=Talonario.objects.get(pk=pkt)
			cp=Comprobante(id_talonario=tln,ticket_numero=ordn.pk,concepto="Genérico",tipo="0",monto=ordn.importe,estado=0)
			cp.save()
			cop=CompOrden(id_comprobante=cp,id_orden=ordn)
			cop.save()
			rpta="Ok"
	return rpta



class CompListarOrd(View):

	def get(self, request, *args, **kwargs):
		pkr = self.request.GET.get('pkr')
		print("  >> pko::"+pkr)
		dicc={}
		if CompOrden.objects.filter(id_orden__id_reparto=pkr).exists():
			dicc["lst_cmp"]=CompOrden.objects.filter(id_orden__id_reparto=pkr).order_by('-pk')
		else:
			dicc["msj"]="Reparto sin comprobantes."

		return render(request,'reparto/lst_comp_ord.html',dicc)



class LstLimpiezas(View):

	def get(self, request, *args, **kwargs):
		dicc={}
		dicc["lst_lmps"]=Limpieza.objects.all().order_by('-pk')
		return render(request,'limpia/lst_lmps.html',dicc)

class LstDestajos(View):

	def get(self, request, *args, **kwargs):
		pkl = self.request.GET.get('pkl')
		print("  >> pkl::"+pkl)
		dicc={}
		if DetLimpieza.objects.filter(id_limpieza=pkl).exists():
			dicc["lst_dstjs"]=DetLimpieza.objects.filter(id_limpieza=pkl).order_by('-pk')
		else:
			dicc['msj']="La limpieza no a generado aún su hoja de revisión."
		return render(request,'limpia/lst_dstjs.html',dicc)


class CrearMulDstj(View):

	def get(self, request, *args, **kwargs):
		pkd = self.request.GET.get('pkd')
		mon = self.request.GET.get('monto')
		con = self.request.GET.get('concepto')
		#print("  >> pkd: "+str(pkd)+"  > monto: "+str(mon)+"  > con:"+str(con))
		rpta = "Err"
		if MultaLimpia.objects.filter(id_det_limpia=pkd).exists():
			print("  >> Err: ya tiene mullta creada, editese.")
			rpta="Inv"
		else:
			dtl=DetLimpieza.objects.get(pk=pkd)
			fch=datetime.datetime.now()
			mlt=Multa(concepto=con,fecha=fch,estado="0",tipo="3",monto=float(mon))
			mlt.save()
			mltl=MultaLimpia(id_multa=mlt,id_det_limpia=dtl)
			mltl.save()
			rpta="Ok"
	
		return HttpResponse(rpta)
		
# =================================== END COMPROBANTE ============	
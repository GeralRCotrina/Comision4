from django.shortcuts import render
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


class ImprimirMulta1(View):

	def get(self, request, *args, **kwargs):
		print(" >> ImprimirMulta")
		pka = self.request.GET.get('pka')
		rpta = 'Ok'
		dicc={}
		if pka != "":
			print('  >> Ok: '+str(pka))
			url='multa/t_imp_1.html'
			dicc['msj']="ók"
			#--------------------------------------------------pdf
			env= Environment(loader=FileSystemLoader("pdf"))
			template = env.get_template("tesorero/impMul1.html")

			path_wkthmltopdf = b'C:\\Program Files\\wkhtmltopdf\\bin\\wkhtmltopdf.exe'
			config = pdfkit.configuration(wkhtmltopdf=path_wkthmltopdf)

			jsn={'fch':datetime.datetime.now()}

			html = template.render(jsn)
			f=open('pdf/tesorero/impMul2.html','w')
			f.write(html)
			f.close()


			options = {'page-size': 'legal','margin-top':'0.1in','margin-right':'0.3in','margin-bottom':'0.9in','margin-left':'0.3in',}

			pdfkit.from_file('pdf/tesorero/impMul2.html', 'static/pdfs/impMul3.pdf',options=options, configuration=config)

			dicc = {}
			dicc['pdf']='Listados de las órdenes por reparto'
			dicc['url_pdf']='pdfs/impMul3.pdf'
			#--------------------------------------------------pdf
			print("  >> finaló 1")
		else:
			print("  >> Err")
		return render(request,url,dicc)



class ImprimirMulta(View):

	def get(self, request, *args, **kwargs):
		print(" >> ImprimirMulta")
		pka = self.request.GET.get('pka')
		rpta = 'Ok'
		dicc={}
		if pka != "":
			print('  >> Ok: '+str(pka))
			url='multa/t_imp_1.html'
			dicc['msj']="ók"
			#--------------------------------------------------pdf
			env = Environment(loader=FileSystemLoader("pdf", encoding = 'utf-8'))
			print("-----0")
			template = env.get_template("tesorero/impMul1.html")
			print("-----1")

			path_wkthmltopdf = b'C:\\Program Files\\wkhtmltopdf\\bin\\wkhtmltopdf.exe'
			print("-----2")
			config = pdfkit.configuration(wkhtmltopdf=path_wkthmltopdf)
			
			dicc['fch']=datetime.datetime.now()

			html = template.render(dicc)
			f=open('pdf/tesorero/impMul2.html','w')
			print(" ----")
			f.write(html)
			print(" ----2")
			f.close()
	 
			options = { 'page-size':'A4','margin-top':'0.2in','margin-right':'0.2in',
				'margin-bottom':'0.3in','margin-left':'0.2in'}

			pdfkit.from_file('pdf/tesorero/impMul2.html', 'static/pdfs/impMul3.pdf',options=options, configuration=config)

			dicc['pdf']='Listados de las órdenes por reparto'
			dicc['url_pdf']='pdfs/impMul3.pdf'
			#--------------------------------------------------pdf
			print("  >> finaló 1")
		else:
			print("  >> Err")
		return render(request,url,dicc)



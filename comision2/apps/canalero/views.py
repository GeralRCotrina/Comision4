from django.shortcuts import render, redirect, render_to_response
from django.http import HttpResponse
from django.urls import reverse_lazy
from django.views.generic import ListView, CreateView, UpdateView, DeleteView, TemplateView, View
from apps.inicio.models import *
from apps.canalero.forms import *


from apps.presidente.forms import ParcelaForm, CanalForm, NoticiaForm
from apps.canalero.forms import LimpiezaForm
from apps.inicio.forms import PersonaForm

from django.contrib.auth.decorators import login_required, permission_required

from django.contrib.auth.models import User
from apps.presidente.forms import RegistroForm

import time
import datetime

import pdfkit
from jinja2 import Environment, FileSystemLoader
from django.utils.dateparse import parse_date
from django.db.models import Q

import json

class AperRep(View):

	def get(self,request,*args,**kwargs):
		idre = self.request.GET.get('id_repa')
		est = self.request.GET.get('std')
		Reparto.objects.filter(pk=int(float(idre))).update(estado=est)

		return redirect('../c_reparto_lis_ord/?id_repa='+idre)



class RepartoRep(View):

	def get(self,request,*args,**kwargs):
		pkr = self.request.GET.get('pkr')
		reparto= Reparto.objects.get(id_reparto=pkr)

		env = Environment(loader=FileSystemLoader("pdf", encoding = 'utf-8'))
		template = env.get_template("canalero/rep_reparto_i.html")
		path_wkthmltopdf = b'C:\\Program Files\\wkhtmltopdf\\bin\\wkhtmltopdf.exe'
		config = pdfkit.configuration(wkhtmltopdf=path_wkthmltopdf)

		from django.db import connection, transaction
		result = []
		cursor = connection.cursor()
		cursor.execute("CALL sp_reparto_rep ("+str(pkr)+")")
		detalles = cursor.fetchall()
		
		for row in detalles:
			dic = dict(zip([col[0] for col in cursor.description], row))
			result.append(dic)
		cursor.close()



		total_or=0
		aprobadas_or=0
		entregadas_or = 0
		rechazadas_or = 0
		importe_re = 0
		deuda_re = 0

		for r in result:
			total_or+=1
			if r['estado'] == 'Aprobada':
				deuda_re+=float(r['importe'])
				aprobadas_or +=1
			elif r['estado'] == 'Entregada':
				importe_re +=float(r['importe'])
				entregadas_or +=1
			elif r['estado'] == 'Rechazada':
				rechazadas_or +=1
		print(" importe: "+str(importe_re))

		jsn={
			'ordenes':result,
			'fecha':' '+time.strftime("%d/%m/%y")+'; '+time.strftime("%X")+' ',
			'total_or':total_or,
			'aprobadas_or':aprobadas_or,
			'entregadas_or':entregadas_or,
			'rechazadas_or':rechazadas_or,
			'importe_re':importe_re,
			'deuda_re':deuda_re,
			'reparto':reparto
		}

		html = template.render(jsn)
		f=open('pdf/canalero/rep_reparto_f.html','w')
		f.write(html)
		f.close()


		options = {'page-size': 'legal','margin-top':'0.2in','margin-right':'0.2in','margin-bottom':'0.4in','margin-left':'0.2in',}
		#pdfkit.from_file('html a renderizar', 'donde y cómo se guarda',options=options, configuration=config)
		pdfkit.from_file('pdf/canalero/rep_reparto_f.html', 'static/pdfs/rep_reparto_p.pdf',options=options, configuration=config)


		dicc = {
			'msj':"llegó el reparto",
			'pdf':'Listados de las órdenes por reparto',
			'url_pdf':'pdfs/rep_reparto_p.pdf'
		}

		return render(request,'reparto/c_reparto_rep.html',dicc)
	
		


class ImpLstOrd(View):

	def get(self,request,*args,**kwargs):
		cad = self.request.GET.get('lst1')
		tam = self.request.GET.get('tam')
		print(" -->>>  "+cad)
		jsn=json.loads(cad)
		t = int(tam)

		env = Environment(loader=FileSystemLoader("pdf", encoding = 'utf-8'))
		template = env.get_template("imprimir.html")

		path_wkthmltopdf = b'C:\\Program Files\\wkhtmltopdf\\bin\\wkhtmltopdf.exe'
		config = pdfkit.configuration(wkhtmltopdf=path_wkthmltopdf)


		from django.db import connection, transaction
		
		result = []
		print(" ---------------------ciclo FOR---- (actualizado)--------------")
		for i in range(t):
			print("  > jsn["+str(i)+"]="+str(jsn[str(i)]))
			
			cursor = connection.cursor()
			cursor.execute("CALL sp_imp_orden ("+str(jsn[str(i)])+")")
			detalles = cursor.fetchall()
			print("                   ->"+str(detalles))
			for row in detalles:
				dic = dict(zip([col[0] for col in cursor.description], row))
				result.append(dic)
			cursor.close()
		
			cursor = connection.cursor()
			cursor.execute("CALL sp_imp_orden (8)")
			detalles = cursor.fetchall()
			cursor.close()


		print(" ---------------------END ciclo FOR------------------")
		

		
		print(' ..')
		print(' ')

		jsn={
			'ordenes':result,
			'fecha':' '+time.strftime("%d/%m/%y")+'; '+time.strftime("%X")+' '
		}

		html = template.render(jsn)
		f=open('pdf/ordenes.html','w')
		f.write(html)
		f.close()

		options = {'page-size': 'legal','margin-top':'0.0in','margin-right':'0.1in','margin-bottom':'0.9in','margin-left':'0.1in',}

		pdfkit.from_file('pdf/ordenes.html', 'static/pdfs/reparto_01.pdf',options=options, configuration=config)

		dicc = {}
		dicc['pdf']='Listados de las órdenes por reparto'
		dicc['url_pdf']='pdfs/reparto_01.pdf'

		return render(request,'reportes/c_pdf_01.html',dicc)


class ImpLstOrd1(View):

	def getget(self,request,*args,**kwargs):
		jsn_lst_ord = self.request.GET.get('lst1')
		print("  > llegó")
		print("   >> "+jsn_lst_ord)
		dic='{"msj":"ok"}'

		return render(request,'reportes/c_pdf_01.html',dic)





class ImprimirReparto(View):

	def get(self,request,*args,**kwargs):		
		idre = self.request.GET.get('id_repa')
		env = Environment(loader=FileSystemLoader("pdf", encoding = 'utf-8'))
		template = env.get_template("imprimir.html")

		path_wkthmltopdf = b'C:\\Program Files\\wkhtmltopdf\\bin\\wkhtmltopdf.exe'
		config = pdfkit.configuration(wkhtmltopdf=path_wkthmltopdf)
		
		from django.db import connection, transaction
		cursor = connection.cursor()
		cursor.execute("CALL sp_imprimir_ordenes (%s)",[idre])

		#print('   ------>>>>esteeee')
		print(' .> '+idre)

		result = []
		detalles = cursor.fetchall()
		for row in detalles:
			dic = dict(zip([col[0] for col in cursor.description], row))
			result.append(dic)
			print(dic)
		cursor.close()

		#print(' ..')
		print(' ')

		jsn={
			'ordenes':result,
			'fecha':' '+time.strftime("%d/%m/%y")+'; '+time.strftime("%X")+' '
		}

		html = template.render(jsn)
		f=open('pdf/ordenes.html','w')
		f.write(html)
		f.close()

		options = {'page-size': 'legal','margin-top':'0.0in','margin-right':'0.1in','margin-bottom':'0.9in','margin-left':'0.1in',}

		pdfkit.from_file('pdf/ordenes.html', 'static/pdfs/reparto_01.pdf',options=options, configuration=config)

		dicc = {}
		dicc['pdf']='Listados de las órdenes por reparto'
		dicc['url_pdf']='pdfs/reparto_01.pdf'

		return render(request,'reportes/c_pdf_01.html',dicc)



#-----------------------------------------------------------------------------------
class ImprimirReparto1(View):

	def get(self,request,*args,**kwargs):
		idre = self.request.GET.get('id_repa')
		env= Environment(loader=FileSystemLoader("pdf"))
		template = env.get_template("imprimir.html")

		path_wkthmltopdf = b'C:\\Program Files\\wkhtmltopdf\\bin\\wkhtmltopdf.exe'
		config = pdfkit.configuration(wkhtmltopdf=path_wkthmltopdf)
		
		from django.db import connection, transaction
		cursor = connection.cursor()
		cursor.execute("CALL sp_imprimir_ordenes (%s)",[idre])

		result = []
		detalles = cursor.fetchall()
		for row in detalles:
		        dic = dict(zip([col[0] for col in cursor.description], row))				
		        result.append(dic)
		cursor.close()

		diccionario={}
		diccionario['ordenes']=result
		diccionario['fecha']= ' '+time.strftime("%d/%m/%y")+'; '+time.strftime("%X")+' '

		html = template.render(diccionario)
		f=open('pdf/ordenes.html','w')
		f.write(html)
		f.close()

		options = { 
			'page-size':'A4',
			'margin-top':'0.0in',
			'margin-right':'0.1in',
			'margin-bottom':'9in',
			'margin-left':'0.1in',
			}

		pdfkit.from_file('pdf/ordenes.html', 'static/pdfs/reparto_01.pdf',options=options, configuration=config)

		dicc = {}
		dicc['pdf']='Listados de las órdenes por reparto'
		dicc['url_pdf']='pdfs/reparto_01.pdf'

		return render(request,'reportes/c_pdf_01.html',dicc)




class PDF_002(View):

	def get(self,request,*args,**kwargs):
		
		env= Environment(loader=FileSystemLoader("pdf"))
		template = env.get_template("tiketD.html")

		path_wkthmltopdf = b'C:\\Program Files\\wkhtmltopdf\\bin\\wkhtmltopdf.exe'
		config = pdfkit.configuration(wkhtmltopdf=path_wkthmltopdf)

		from django.db import connection, transaction
		cursor = connection.cursor()
		cursor.execute("CALL sp_rep_reparto")
		result = []
		detalles = cursor.fetchall()
		for row in detalles:
		        dic = dict(zip([col[0] for col in cursor.description], row))				
		        result.append(dic)
		cursor.close()
		diccionario={}
		diccionario['repartos']=result
		diccionario['fecha']= ' '+time.strftime("%d/%m/%y")+'; '+time.strftime("%X")+' '
		

		html = template.render(diccionario)
		f=open('pdf/ordenes.html','w')
		f.write(html)
		f.close()

		options = { 
			'page-size':'A4',
			'margin-top':'0.1in',
			'margin-right':'0.0in',
			'margin-bottom':'0.0in',
			'margin-left':'0.0in',
			}

		pdfkit.from_file('pdf/ordenes.html', 'static/pdfs/reparto_01.pdf',options=options, configuration=config)

		dicc = {}
		dicc['pdf']='Listados de las ordenes por reparto'
		dicc['url_pdf']='pdfs/reparto_01.pdf'

		return render(request,'reportes/c_pdf_01.html',dicc)

 
class PDF_001(View):

	def get(self,request,*args,**kwargs):
		
		env= Environment(loader=FileSystemLoader("pdf"))
		template = env.get_template("pdf_reparto.html")

		path_wkthmltopdf = b'C:\\Program Files\\wkhtmltopdf\\bin\\wkhtmltopdf.exe'
		config = pdfkit.configuration(wkhtmltopdf=path_wkthmltopdf)

		from django.db import connection, transaction
		cursor = connection.cursor()
		cursor.execute("CALL sp_rep_reparto")
		result = []
		detalles = cursor.fetchall()
		for row in detalles:
		        dic = dict(zip([col[0] for col in cursor.description], row))				
		        result.append(dic) 
		cursor.close()
		diccionario={}
		diccionario['repartos']=result
		diccionario['fecha']= ' '+time.strftime("%d/%m/%y")+'; '+time.strftime("%X")+' '
		

		html = template.render(diccionario)
		f=open('pdf/reparto.html','w')
		f.write(html)
		f.close()

		options = { 'page-size':'A4','margin-top':'0.2in','margin-right':'0.2in',
			'margin-bottom':'0.2in','margin-left':'0.2in',	}

		pdfkit.from_file('pdf/reparto.html', 'static/pdfs/reparto_01.pdf',options=options, configuration=config)

		dicc = {}
		dicc['pdf']='Listados de las ordenes por reparto'
		dicc['url_pdf']='pdfs/reparto_01.pdf'

		return render(request,'reportes/c_pdf_01.html',dicc)



#return render(request,'canalero.html')


class GrafRepC1(View):

	def get(self, request, *args, **kwargs):
		dicc={}	
		can=Canal.objects.all()
		ree=Reparto.objects.all()
		for r in ree:
			print(' r:',r)
		for c in can:
			print(' c:',c)


		from django.db import connection, transaction
		cursor = connection.cursor()
		cursor.execute("CALL sp_ordenes_por_reparto_por_canal")
		result = []
		detalles = cursor.fetchall()
		for row in detalles:
		        dic = dict(zip([col[0] for col in cursor.description], row))				
		        result.append(dic)
		cursor.close()
		
		dicc['sp']=result	
		dicc['canales']=can	
		dicc['repartos'] = ree

		return render(request,'reportes/c_graf_rep.html',dicc)














from django.db import connection, transaction	

class RepPeparto(View):

	def get(self, request, *args, **kwargs):
		cursor = connection.cursor()
		cursor.execute("CALL sp_cant_por_reparto")
		result = []
		detalles = cursor.fetchall()
		for row in detalles:
		        dic = dict(zip([col[0] for col in cursor.description], row))				
		        result.append(dic)
		cursor.close()
		diccionario={}
		diccionario['repartos']=result
		for d in result:
			print('   - -  - >',d)
		return render(request,'reportes/c_reporte_rep.html',diccionario)


class RepCaudal2(View):

	def get(self, request, *args, **kwargs):				
		can=Canal.objects.all()
		cau=Caudal.objects.all()
		reporte_caudal = {}
		reporte_caudal['canales']=can
		reporte_caudal['caudal']=cau
		return render(request,'reportes/c_reporte_cau.html',reporte_caudal)



class RepCaudal(View):

	def get(self, request, *args, **kwargs):				
		can=Canal.objects.all()
		cau=Caudal.objects.all().order_by("-pk")
		cant_can=can.count()
		cant_cau=(cau.count()/cant_can)
		t=datetime.datetime.now()
		reporte_caudal = {}
		reporte_caudal['fecha']=datetime.datetime.now()
		reporte_caudal['canales']=can
		reporte_caudal['caudal']=cau
		reporte_caudal['cant_can']=cant_can
		reporte_caudal['cant_cau']=cant_cau
		return render(request,'reportes/c_reporte_caudal.html',reporte_caudal)







@permission_required('inicio.es_canalero')
def canalero(request):
	return render(request, 'canalero.html')







class SolicitudesPorReparto(TemplateView):

	def get(self, request, *args, **kwargs):
		idrepa = self.request.GET.get('id_repa')
		dicc={}
		dicc['reparto']=Reparto.objects.get(id_reparto=idrepa)
		dicc['repartos']=Reparto.objects.all().order_by('-id_reparto')
		dicc['ordenes']=OrdenRiego.objects.filter(id_reparto=idrepa).order_by('-id_reparto')
		return render(request,'reparto/c_reparto_lis_ord.html',dicc)
 


class AprobarOrden(TemplateView):

	def get(self, request, *args, **kwargs):
		idord = self.request.GET.get('id_ord')
		idrep = self.request.GET.get('id_rep')		
		est = self.request.GET.get('est')
		orr=OrdenRiego.objects.get(id_orden_riego=int(idord))
		orr.estado=est
		orr.save()

		dicc={}
		dicc['reparto']=Reparto.objects.get(id_reparto=idrep)
		dicc['repartos']=Reparto.objects.all()
		dicc['ordenes']=OrdenRiego.objects.filter(id_reparto=idrep)
		return HttpResponse(dicc)


class EstablecerHora(TemplateView):

	def get(self,request,*args,**kwargs):
		idord = self.request.GET.get('id_ord')
		diccionario ={}
		diccionario['orden']=OrdenRiego.objects.get(pk=idord)
		return render(request,'reparto/c_orden_hora.html',diccionario)

	def post(self,request,*args,**kwargs):
		fec = self.request.POST.get('fecha')
		hor = self.request.POST.get('horas')
		minu = self.request.POST.get('minutos')
		idord = self.request.POST.get('idord')
		idrepa = self.request.POST.get('idrepa')
		actu = self.request.POST.get('actu')


		dd = parse_date(fec)
		dt=datetime.datetime(year=dd.year,month=dd.month,day=dd.day)
		dt=dt+datetime.timedelta(hours=float(hor))
		dt=dt+datetime.timedelta(minutes=float(minu))

		OrdenRiego.objects.filter(pk=int(float(idord))).update(fecha_establecida=dd)
		OrdenRiego.objects.filter(pk=int(float(idord))).update(fecha_inicio=dt)

		if actu != 'on':
			CalcularHora(int(float(idord)))
		urll='../c_reparto_lis_ord/?id_repa='+str(idrepa)
		return redirect(urll)


def CalcularHora(idord):
	orde=OrdenRiego.objects.get(pk=idord)
	can=orde.id_parcela.id_canal.pk
	idrepa=orde.id_reparto.pk
	dicc=OrdenRiego.objects.filter(Q(id_reparto__pk=idrepa),Q(id_parcela__id_canal__pk=can),Q(estado__exact='Aprobada'))

	hr=orde.fecha_inicio
	nto=orde.id_parcela.num_toma

	for o in dicc:
		if o.pk == orde.pk:
			print(' >>> esta es::',o.id_parcela.nombre)
		else:
			if o.id_parcela.num_toma > nto:
				hr = hr+ datetime.timedelta(minutes=15)
				hr = hr+ datetime.timedelta(hours=o.duracion)
				OrdenRiego.objects.filter(pk=o.pk).update(fecha_inicio=hr)
				OrdenRiego.objects.filter(pk=o.pk).update(fecha_establecida=hr.date())





def edirtar_usuario(request,id_usuario):
	usuario=Usuario.objects.get(id=id_usuario)
	if request.method == "GET":
		form=UsuarioForm(instance=usuario)
	else:
		form = UsuarioForm(request.POST,instance=usuario)
		if form.is_valid():
			form.save()
			return redirect('lista_usuarios')
	return render(request,'registrar_usuario.html', {'form':form})



class AprobarListaOrdenes(TemplateView):

	def get(self, request, *args, **kwargs):
		idrep = self.request.GET.get('id_rep')
		estrep = self.request.GET.get('est_rep')
		lo=OrdenRiego.objects.filter(id_reparto=idrep)
		for l in lo:
			l.estado=estrep
			l.save()
		dicc={}
		dicc['reparto']=Reparto.objects.get(id_reparto=idrep)
		dicc['repartos']=Reparto.objects.all().order_by('-id_reparto')
		dicc['ordenes']=OrdenRiego.objects.filter(id_reparto=idrep)
		return render(request,'reparto/c_reparto_lis_ord.html',dicc)



class DestajoCreate(CreateView):
	model=Destajo
	form_class=DestajoForm
	template_name='destajo/c_destajo_reg.html'
	success_url=reverse_lazy('c_destajo_lis')



class DestajoList(View):
	
	def get(self, request, *args, **kwargs):
		dicc ={}
		dicc['canales']=Canal.objects.all()
		if self.request.GET.get('idc'):
			idc = self.request.GET.get('idc')
			dicc['object_list']=Destajo.objects.filter(id_canal=idc)
		else:
			dicc['object_list']=Destajo.objects.all()
		return  render(request,'destajo/c_destajo_lis.html',dicc)





"""
class DestajoList(ListView):
	model=Destajo
	template_name='destajo/c_destajo_lis.html'
	paginate_by=50

	def get_queryset(self):
		queryset = Destajo.objects.all().order_by('-pk')
		return queryset

# object_list
# queryset = Destajo.objects.all().order_by('-pk')
"""


class DestajoUpdate(UpdateView):
	model=Destajo
	form_class=DestajoForm
	template_name='destajo/c_destajo_reg.html'
	success_url=reverse_lazy('c_destajo_lis') 

class DestajoDelete(DeleteView):
	model=Destajo
	form_class=DestajoForm
	template_name='destajo/c_destajo_eli.html'
	success_url=reverse_lazy('c_destajo_lis')

























class MultaList(ListView):
	model=Multa
	template_name='multa/c_multa_lis.html'
	paginate_by=10

class MultaUpdate(UpdateView):
	model=Multa
	form_class=MultaForm
	template_name='multa/c_multa_reg.html'
	success_url=reverse_lazy('c_multa_lis') 

class MultaDelete(DeleteView):
	model=Multa
	form_class=MultaForm
	template_name='multa/c_multa_eli.html'
	success_url=reverse_lazy('c_multa_lis')




    
class MultaCreate(CreateView):
	model=Multa
	form_class=MultaForm
	template_name='multa/c_multa_reg.html'
	success_url=reverse_lazy('c_multa_lis')

	def get(self, request, *args, **kwargs):
		print("  > > GET de CreateView")
		#return  render(request,'destajo/c_destajo_lis.html',dicc)
		return render(request, self.template_name, {'form': self.form_class} )


	def post(self,request,*args,**kwargs):
		print("  > > POST de CreateView")
		jsn = {}

		concept = self.request.POST.get('concepto')
		estad = self.request.POST.get('estado')
		tip = self.request.POST.get('tipo')
		fech = datetime.datetime.now().strftime("%Y-%m-%d")

		if self.request.POST.get('tipo') == "0":
			lstaa = HojaAsistencia.objects.all()
		elif self.request.POST.get('tipo') == "1":
			lstaa = Destajo.objects.all()
		elif self.request.POST.get('tipo') == "2":
			lstaa = OrdenRiego.objects.all()
		else:
			print(" > Err")

		mult = Multa(concepto=concept,fecha=fech,estado=estad,tipo=tip)

		print("  > name: "+concept+" > "+str(fech)+" > "+str(estad)+" > "+str(tip))
		
		return render(request,'multa/c_mul_fin.html', {'lstaa': lstaa} )
   








class CanalCreate(CreateView):
	model=Canal
	form_class=CanalForm
	template_name='canal/c_canal_reg.html'
	success_url=reverse_lazy('c_canal_lis')

class CanalList(ListView):
	model=Canal
	template_name='canal/c_canal_lis.html'
	paginate_by=9

class CanalUpdate(UpdateView):
	model=Canal
	form_class=CanalForm
	template_name='canal/c_canal_reg.html'
	success_url=reverse_lazy('c_canal_lis') 

class CanalDelete(DeleteView):
	model=Canal
	form_class=CanalForm
	template_name='canal/c_canal_eli.html'
	success_url=reverse_lazy('c_canal_lis')



 
class ParcelaCreate(CreateView):
	model=Parcela
	form_class=ParcelaForm
	template_name='parcela/c_parcela_reg.html'
	success_url=reverse_lazy('c_parcela_lis')

class ParcelaList(ListView):
	model=Parcela
	template_name='parcela/c_parcela_lis.html'
	paginate_by=9

class ParcelaUpdate(UpdateView):
	model=Parcela
	form_class=ParcelaForm
	template_name='parcela/c_parcela_reg.html'
	success_url=reverse_lazy('c_parcela_lis') 

class ParcelaDelete(DeleteView):
	model=Parcela
	form_class=ParcelaForm
	template_name='parcela/c_parcela_eli.html'
	success_url=reverse_lazy('c_parcela_lis')




class NoticiaCreate(CreateView):
	model=Noticia
	form_class=NoticiaForm
	template_name='noticia/c_noticia_reg.html'
	success_url=reverse_lazy('c_noticia_lis')

class NoticiaList(ListView):
	model=Noticia
	template_name='noticia/c_noticia_lis.html'
	paginate_by=9

class NoticiaUpdate(UpdateView):
	model=Noticia
	form_class=NoticiaForm
	template_name='noticia/c_noticia_reg.html'
	success_url=reverse_lazy('c_noticia_lis') 

class NoticiaDelete(DeleteView):
	model=Noticia
	form_class=NoticiaForm
	template_name='noticia/c_noticia_eli.html'
	success_url=reverse_lazy('c_noticia_lis')

 



class RepartoCreate(CreateView):
	model=Reparto
	form_class=RepartoForm
	template_name='reparto/c_reparto_reg.html'
	success_url=reverse_lazy('c_reparto_lis')

class RepartoList(ListView):
	model=Reparto
	template_name='reparto/c_reparto_lis.html'
	paginate_by=4

	def get_queryset(self):
		queryset = Reparto.objects.all().order_by('-pk')
		return queryset

class RepartoUpdate(UpdateView):
	model=Reparto
	form_class=RepartoForm
	template_name='reparto/c_reparto_reg.html'
	success_url=reverse_lazy('c_reparto_lis') 

class RepartoDelete(DeleteView):
	model=Reparto
	form_class=RepartoForm
	template_name='reparto/c_reparto_eli.html'
	success_url=reverse_lazy('c_reparto_lis')



 
class UsuarioDelete(DeleteView):
	model=DatosPersonales
	form_class=PersonaForm
	template_name='usuario/c_usuario_eli.html'
	success_url=reverse_lazy('c_usuario_lis')

class UsuarioUpdate(UpdateView):
	model=DatosPersonales
	form_class=PersonaForm
	template_name='usuario/c_usuario_reg.html'
	success_url=reverse_lazy('c_usuario_lis') 

class UsuarioCreate(CreateView):
	model=DatosPersonales
	form_class=PersonaForm
	template_name='usuario/c_usuario_reg.html'
	success_url=reverse_lazy('c_usuario_lis')

class UsuarioList(ListView):
	model=DatosPersonales
	template_name='usuario/c_usuario_lis.html'
	paginate_by=9




class RegistrarUsuario(CreateView):
	model = User 
	template_name="usuario/c_crear_user.html"
	form_class = RegistroForm
	success_url=reverse_lazy('RegistrarUsuario')





 
class LimpiaDelete(DeleteView):
	model=Limpieza
	form_class=LimpiezaForm
	template_name='limpia/c_limpia_eli.html'
	success_url=reverse_lazy('c_limpia_lis')

	def get(self, request, *args, **kwargs):
		print("  > > GET de DeleteView")
		pkl=self.kwargs.get('pk')
		print("  >>  --|- "+str(pkl))
		return render(request, self.template_name, {'form': self.form_class} )


	def post(self,request,*args,**kwargs):
		print("  > > POST de DeleteView")
		pkl=self.kwargs.get('pk')
		lmp=Limpieza.objects.get(pk=pkl)
		if DetLimpieza.objects.filter(id_limpieza=lmp).exists():
			DetLimpieza.objects.filter(id_limpieza=lmp).delete()
		lmp.delete()
		object_list = Limpieza.objects.all().order_by('-pk')
		return render(request, 'limpia/c_limpia_lis.html', {'object_list': object_list} )


class LimpiaUpdate(UpdateView):
	model=Limpieza
	form_class=LimpiezaForm
	template_name='limpia/c_limpia_reg.html'
	success_url=reverse_lazy('c_limpia_lis') 

class LimpiaCreate(CreateView):
	model=Limpieza
	form_class=LimpiezaForm
	template_name='limpia/c_limpia_reg.html'
	success_url=reverse_lazy('c_limpia_lis')

class LimpiaList(ListView):
	model=Limpieza
	template_name='limpia/c_limpia_lis.html'
	paginate_by=9

	def get(self, request, *args, **kwargs):
		pkl=self.kwargs.get('pk')
		object_list = Limpieza.objects.all().order_by('-pk')
		return render(request, self.template_name, {'object_list': object_list} )

class LimpiaRev(View):

	def get(self, request, *args, **kwargs):
		dicc ={}
		pkl=self.kwargs.get('pk')

		dicc['lmp']=Limpieza.objects.get(pk=pkl)
		limp=Limpieza.objects.get(pk=pkl)

		if Limpieza.objects.filter(pk=pkl).exists():
			print("  >> existe la limpia, bueno llegó")
			if DetLimpieza.objects.filter(id_limpieza=limp).exists():
				print("  >> ya tiene su detalle ")
			else:
				print("  >> se creará detalle")
				if Limpieza.objects.get(pk=pkl).tipo == "0":
					print("  >> es GENERAL")
					tds=Destajo.objects.all()
					for d in tds:
						dtlmp = DetLimpieza(id_destajo=d,id_limpieza=limp,estado="0",fecha="2019-01-01 00:00:00")
						dtlmp.save()

				elif Limpieza.objects.get(pk=pkl).tipo == "1":
					print("  >> es DESFAGINE MATRIZ")
					tds=Destajo.objects.filter(id_canal=1)
					for d in tds:
						dtlmp = DetLimpieza(id_destajo=d,id_limpieza=limp,estado="0",fecha="2019-01-01 00:00:00")
						dtlmp.save()

				elif Limpieza.objects.get(pk=pkl).tipo == "2":
					print("  >> es DESFAGINE RAMALES")
					tds=Destajo.objects.exclude(id_canal=1)
					for d in tds:
						dtlmp = DetLimpieza(id_destajo=d,id_limpieza=limp,estado="0",fecha="2019-01-01 00:00:00")
						dtlmp.save()

				else:
					print("  >> Err ")

		if DetLimpieza.objects.filter(id_limpieza=limp).exists():
			dicc['destajos']=DetLimpieza.objects.filter(id_limpieza=limp)

		return  render(request,'limpia/c_limp_rev.html',dicc)


class DetLimpEst(View):

	def get(self, request, *args, **kwargs):
		pkd = request.GET.get('pkd')
		std = request.GET.get('std')
		
		if DetLimpieza.objects.filter(pk=pkd).exists():
			hr= datetime.datetime.now()
			DetLimpieza.objects.filter(pk=pkd).update(estado=std,fecha=hr)
		return  HttpResponse('ok')

	def post(self, request, *args, **kwargs):
		pkl = request.POST.get('pk_lmp')
		print("  >> POST "+str(pkl))
		lista= DetLimpieza.objects.filter(id_limpieza=pkl)
		hr= datetime.datetime.now()
		for l in lista:
			l.estado='1'
			l.fecha=hr
			l.save()
		print("  >> end")



		dicc={}
		dicc['lmp']=Limpieza.objects.get(pk=pkl)
		if DetLimpieza.objects.filter(id_limpieza=pkl).exists():
			dicc['destajos']=DetLimpieza.objects.filter(id_limpieza=pkl)

		return  render(request,'limpia/c_limp_rev.html',dicc)






class LimpiaPie(View):

	def get(self, request, *args, **kwargs):
		pkl=self.kwargs.get('pk')
		lmp=Limpieza.objects.get(pk=pkl)
		dicc={}
		dicc['lmp']=lmp
		dtlmp=DetLimpieza.objects.filter(id_limpieza=pkl)		
		dicc['dtlmp']=dtlmp
		hr= datetime.datetime.now()
		dicc['hr']=hr

		dm=0
		dn=0
		db=0
		df=0

		for dl in dtlmp:
			if dl.estado == '1':
				db+=1
			elif dl.estado == '2':
				dm+=1
			elif dl.estado == '3':
				dn+=1
			elif dl.estado == '0':
				df +=1
			else:
				print("Err")


		dicc['dm']=dm
		dicc['dn']=dn
		dicc['db']=db
		dicc['df']=df

		print("  >> ok "+str(dtlmp.count())+" db="+str(db)+"  hr="+str(hr))
		
		return  render(request,'limpia/c_limpia_pie.html',dicc)




class LimpiaPdf(View):

	def get(self, request, *args, **kwargs):
		pkl=self.kwargs.get('pk')
		lmp=Limpieza.objects.get(pk=pkl)
		diccionario={}
		diccionario['lmp']=lmp
		dtlmp=DetLimpieza.objects.filter(id_limpieza=pkl)		
		diccionario['dtlmp']=dtlmp
		hr= datetime.datetime.now()
		diccionario['hr']=hr

		dm=0
		dn=0
		db=0
		df=0

		for dl in dtlmp:
			if dl.estado == '1':
				db+=1
			elif dl.estado == '2':
				dm+=1
			elif dl.estado == '3':
				dn+=1
			elif dl.estado == '0':
				df +=1
			else:
				print("Err")


		diccionario['dm']=dm
		diccionario['dn']=dn
		diccionario['db']=db
		diccionario['df']=df
		diccionario['dt']=dtlmp.count()

		env= Environment(loader=FileSystemLoader("pdf"))
		template = env.get_template("canalero/limp_i.html")

		path_wkthmltopdf = b'C:\\Program Files\\wkhtmltopdf\\bin\\wkhtmltopdf.exe'
		config = pdfkit.configuration(wkhtmltopdf=path_wkthmltopdf)
		
		from django.db import connection, transaction
		cursor = connection.cursor()
		cursor.execute("CALL sp_dtlimpieza (%s)",[pkl])

		result = []
		detalles = cursor.fetchall()
		for row in detalles:
		        dic = dict(zip([col[0] for col in cursor.description], row))				
		        result.append(dic)
		        print("  >> "+str(dic))
		cursor.close()

		diccionario['dtlmp']=result
		diccionario['fecha']= ' '+time.strftime("%d/%m/%y")+'; '+time.strftime("%X")+' '

		html = template.render(diccionario)
		f=open('pdf/canalero/limp_f.html','w')
		f.write(html)
		f.close()

		options = { 
			'page-size':'A4',
			'margin-top':'0.2in',
			'margin-right':'0.2in',
			'margin-bottom':'0.3in',
			'margin-left':'0.2in',
			}

		pdfkit.from_file('pdf/canalero/limp_f.html', 'static/pdfs/c_lmp.pdf',options=options, configuration=config)

		dicc = {}
		dicc['pdf']='Listados de las órdenes por reparto'
		dicc['url_pdf']='pdfs/c_lmp.pdf'

		return render(request,'limpia/c_limpia_pdf.html',dicc)
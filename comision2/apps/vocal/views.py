from django.shortcuts import render
from django.contrib.auth.decorators import login_required, permission_required
from django.views.generic import ListView, CreateView,UpdateView,DeleteView, TemplateView, View
from apps.inicio.models import *
from django.http import HttpResponse


import pdfkit
from jinja2 import Environment, FileSystemLoader



import time
import datetime
from django.utils.dateparse import parse_date
import locale
locale.setlocale(locale.LC_ALL, "")# Establecemos el locale de nuestro sistema


@permission_required('inicio.es_vocal')
def vocal(request):
	return render(request, 'vocal.html')


 


class AsmbLstPdf(View):

	def get(self, request, *args, **kwargs):
		pka = self.request.GET.get('id_asamb')
		Asmb=Asamblea.objects.get(pk=pka)

		env = Environment(loader=FileSystemLoader("pdf", encoding = 'utf-8'))
		template = env.get_template("vocal/lstAsistencia.html")

		path_wkthmltopdf = b'C:\\Program Files\\wkhtmltopdf\\bin\\wkhtmltopdf.exe'
		config = pdfkit.configuration(wkhtmltopdf=path_wkthmltopdf)
		
		from django.db import connection, transaction
		cursor = connection.cursor()
		cursor.execute("CALL sp_hoja_asistencia (%s)",[pka])

		print(' ')
		cont = 0
		a=0
		b=0
		c=0
		d=0

		result = []
		detalles = cursor.fetchall()
		for row in detalles:
			dic = dict(zip([col[0] for col in cursor.description], row))
			cont += 1
			dic['Item']=cont
			if dic['estado'] == "1":
				a+=1
			elif dic['estado'] == "2":
				b+=1
			elif dic['estado'] == "3":
				c+=1
			else:
				d+=1
			result.append(dic)
		cursor.close()

		print(' ..') 

		jsn={
			'Asmb':Asmb,
			'asistencias':result,
			'fecha':' '+time.strftime("%d/%m/%y")+'; '+time.strftime("%X")+' ',
			'a':a,
			'b':b,
			'c':c,
			'd':d,
		}

		html = template.render(jsn)
		f=open('pdf/ordenes.html','w')
		f.write(html)
		f.close()

		options = {'page-size': 'legal','margin-top':'0.1in','margin-right':'0.3in','margin-bottom':'0.9in','margin-left':'0.3in',}

		pdfkit.from_file('pdf/ordenes.html', 'static/pdfs/reparto_01.pdf',options=options, configuration=config)

		dicc = {}
		dicc['pdf']='Listados de las órdenes por reparto'
		dicc['url_pdf']='pdfs/reparto_01.pdf'
		return render(request,'asamblea/pdfs/v_asamb_p1.html',dicc)


		#return render(request,'c_pdf_01.html',dicc)


		



class AsmbGrfRep(View):


	def get(self, request, *args, **kwargs):
		pka = self.request.GET.get('id_asamb')
		Asmb=Asamblea.objects.get(pk=pka)
		lstHAsis = HojaAsistencia.objects.filter(id_asamblea=Asmb)
	
		a=0
		b=0
		c=0
		d=0

		for x in lstHAsis:
			if x.estado == "1":
				a+=1
			elif x.estado == "2":
				b+=1
			elif x.estado == "3":
				c+=1
			else:
				d+=1

		jsn = {
			'a':a,
			'b':b,
			'c':c,
			'd':d,
			'Asmb':Asmb,
			'lstHAsis':lstHAsis
		}
		return render(request,'asamblea/graficos/v_asamb_g1.html',jsn)
		

class AsambLis(View):
	def get(self, request, *args, **kwargs):
		ListAsamb = Asamblea.objects.all().order_by('-id_asamblea')
		return render(request,'asamblea/v_asamb_lis.html',{'asambleas':ListAsamb})

class AsambEdi(View):
	def get(self, request, *args, **kwargs):
		pka = self.request.GET.get('id_asamb')
		asamb = Asamblea.objects.get(pk=pka)
		return render(request,'asamblea/v_asamb_edi.html',{'msj':'editando asamblea.','asamb':asamb})

	def post(self,request,*args,**kwargs):
		pka =  self.request.POST.get('id_asamb')
		desc =  self.request.POST.get('descripcion_asamb')
		fec =  self.request.POST.get('fecha_asamb')
		hor =  self.request.POST.get('hora_asamb')
		tipo =  self.request.POST.get('tipo_asamb')
		est =  self.request.POST.get('estado_asamb')
		HorArr = hor.split(':')
		FecArr = fec.split('/')

		fech = parse_date(fec)
		dt=datetime.datetime(year=int(FecArr[2]),month=int(FecArr[1]),day=int(FecArr[0]))
		dt=dt+datetime.timedelta(hours=float(HorArr[0]))
		dt=dt+datetime.timedelta(minutes=float(HorArr[1]))
		Asamblea.objects.filter(pk=int(float(pka))).update(tipo=tipo,descripcion=desc,fecha_asamblea=dt,estado=int(float(est)))
		ListAsamb = Asamblea.objects.all()
		return render(request,'asamblea/v_asamb_lis.html',{'msj':'Se editó correctamente.','asambleas':ListAsamb})

"""
class AsmbList(View):

	def get(self, request, *args, **kwargs):
		asmb= Asamblea.objects.all().order_by('-id_asamblea');
		return render(request,'asamblea/v_asamb_lis.html',{'Asambleas':asmb})

	def post(self, request, *args, **kwargs):
		dicc={}
		usuario = self.request.POST.get('usuario')
		dicc['userr']= usuario
		if AuthUser.objects.filter(username__exact=usuario).exists():
			print('__________No hay nueva contraseña aún..')
			u=AuthUser.objects.get(username__exact=usuario)
			dicc['passs']= u.password
			dicc['usuario']= usuario
			dicc['msj']= 'nda'
		else:
			dicc['msj']= 'nusr'
		return render(request,'v_act_usu.html',dicc)
"""
class AsambIni(View):
	def get(self, request, *args, **kwargs):
		pka = self.request.GET.get('id_asamb') 
		asamb = Asamblea.objects.get(pk=pka)
		#asamb(estado=2)
		asamb.save()
		lstHAsis = HojaAsistencia.objects.filter(id_asamblea=asamb)

		return  render(request,'asamblea/v_asamb_asis.html',{'msj':'CREADA 1','lstHAsis':lstHAsis})


class HjaAsisEst(TemplateView):
	def get(self, request, *args, **kwargs):
		idhje = self.request.GET.get('id_hje')		
		est = self.request.GET.get('std')

		hja=HojaAsistencia.objects.get(id_hoja_asistencia =int(idhje))
		if est == 'Asistio':
			hja.estado='1'
		elif est == 'Tarde':
			hja.estado='2'
		elif est == 'Falto':
			hja.estado='3'
		else:
			print("    >> ERR: "+str(est))
		hja.hora=datetime.datetime.now()
		hja.save() 
		dicc={}
		dicc['msj1']="OK"
		return HttpResponse(dicc)


class AsmbDel(View):
	
	def get(self, request, *args, **kwargs):
		asmb = self.request.GET.get('pka')
		
		if AgendaAsamblea.objects.filter(id_asamblea=asmb).exists():
			AgendaAsamblea.objects.filter(id_asamblea=asmb).delete()
			print("  >> Eliminó agenda.")
		if HojaAsistencia.objects.filter(id_asamblea=asmb).exists():
			HojaAsistencia.objects.filter(id_asamblea=asmb).delete()
			print("  >> Eliminó la hoja de asistencias.")
		if DetAsambCanal.objects.filter(id_asamblea=asmb).exists():
			DetAsambCanal.objects.filter(id_asamblea=asmb).delete()
			print("  >> Eliminó el detalle de canales.")
		if Asamblea.objects.get(id_asamblea=asmb):
			Asamblea.objects.get(id_asamblea=asmb).delete()
			print("  >> Eliminó la asamblea.")	

		return HttpResponse("ok")



from django.db.models import Q
class HasisGen(View):

	def get(self, request, *args, **kwargs):
		pk_asmb = self.request.GET.get("id_asamb")
		Asmb = Asamblea.objects.get(id_asamblea=pk_asmb)
		cont = 0
		asmbl=Asamblea.objects.get(pk=pk_asmb)

		if asmbl.estado == "1" :
			Asamblea.objects.filter(pk=int(float(pk_asmb))).update(estado="2")
			print("  >se inició la asamblea.")

		if HojaAsistencia.objects.filter(id_asamblea=pk_asmb).exists():
			print("  >>ya tiene hoja de asistencia creada.")
		else:
			if Asmb.tipo == "General":
				parc = Parcela.objects.all()
				for p in parc :
					if HojaAsistencia.objects.filter(Q(id_asamblea=pk_asmb) & Q(id_auth_user=p.id_auth_user)).exists():
						cont +=1
						#print("     ------ya está gg")
						#ff = HojaAsistencia.objects.filter(Q(id_asamblea=pk_asmb) & Q(id_auth_user=p.id_auth_user))
						#for x in ff:
						#	print("        > "+str(x.id_auth_user))
					else:
						#print("  >> no está : "+str(p.id_auth_user)+" -->"+pk_asmb)
						Hasis = HojaAsistencia(id_asamblea=asmbl,id_auth_user=p.id_auth_user,estado="0",hora="2000-12-12 12:00:00")
						Hasis.save()
				#print("se creó la asamblea y su hoja de asistencia.")
			elif Asmb.tipo == "Simple":
				detc = DetAsambCanal.objects.filter(id_asamblea=pk_asmb)
				for x in detc:
					parc=Parcela.objects.filter(id_canal=x.id_canal)
					for p in parc :
						if HojaAsistencia.objects.filter(Q(id_asamblea=pk_asmb) & Q(id_auth_user=p.id_auth_user)).exists():
							#print("     ------ya está ss")
							#ff = HojaAsistencia.objects.filter(Q(id_asamblea=pk_asmb) & Q(id_auth_user=p.id_auth_user))
							#for x in ff:
							#	print("        > "+str(x.id_auth_user))
							cont +=1
						else:
							#print("  >> no está : "+str(p.id_auth_user)+" -->"+pk_asmb)
							Hasis = HojaAsistencia(id_asamblea=asmbl,id_auth_user=p.id_auth_user,estado="0",hora="2000-12-12 12:00:00")
							Hasis.save()
			print("  >>Se creó la hoja de asistencia [rep:"+str(cont)+"].")

		

		lstHAsis = HojaAsistencia.objects.filter(id_asamblea=Asmb)

		
		a=0
		b=0
		c=0
		d=0
		for x in lstHAsis:
			if x.estado == "1":
				a+=1
			elif x.estado == "2":
				b+=1
			elif x.estado == "3":
				c+=1
			else:
				d+=1

		jsn = {
			'a':a,
			'b':b,
			'c':c,
			'd':d,
			'Asmb':Asmb,
			'lstHAsis':lstHAsis,
		}

		return  render(request,'asamblea/v_asamb_asis.html',jsn)


class AsambReg(View):
	def get(self, request, *args, **kwargs):
		return render(request,'asamblea/v_asamb_reg.html')

	def post(self,request,*args,**kwargs):
		desc =  self.request.POST.get('descripcion_asamb')
		fec =  self.request.POST.get('fecha_asamb')
		hor =  self.request.POST.get('hora_asamb')
		tipo =  self.request.POST.get('tipo_asamb')	
		itm_cant =  self.request.POST.get('itm_cant')

		HorArr = hor.split(':')		


		fech = parse_date(fec)
		dt=datetime.datetime(year=fech.year,month=fech.month,day=fech.day)
		dt=dt+datetime.timedelta(hours=float(HorArr[0]))
		dt=dt+datetime.timedelta(minutes=float(HorArr[1]))
		print("3")
		dtr =  datetime.datetime.now()

		asamb=Asamblea(tipo=tipo,descripcion=desc,fecha_registro=dtr,fecha_asamblea=dt,estado=1)
		asamb.save()

		itmc=99
		for x in range(0,int(itm_cant)-99):
			itmc +=1
			ag_as=AgendaAsamblea(id_asamblea=asamb,punto_numero=(int(itm_cant)-99),descripcion=self.request.POST.get(str(itmc)))
			ag_as.save()

		if tipo == "Simple":
			rc=1000
			diccc={}
			for x in range(1,6):
				rc+=1
				if str(self.request.POST.get(str(rc))) == "on":
					cn=Canal.objects.get(id_canal=x)
					dac=DetAsambCanal(id_asamblea=asamb,id_canal=cn)
					dac.save()
			print("  >> Se crearon los detalles de canal.")
		else:
			print("  >> NO se crearon los detalles.")

		return render(request,'asamblea/v_asamb_reg.html',{'msj':'Se guardó correctamente.+'})


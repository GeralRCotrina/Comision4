from django.shortcuts import render, redirect
from apps.inicio.models import DatosPersonales, OrdenRiego, Noticia, Parcela, AuthUser, Reparto, AuthUser, Caudal, Destajo
from apps.inicio.models import *
from apps.inicio.forms import PersonaForm
from apps.usuario.forms import OrdenRForm, AuthUserForm
from django.http import HttpResponse

from django.urls import reverse_lazy
from django.views.generic import ListView, CreateView,UpdateView,DeleteView, TemplateView, View
 
import datetime
import time

from django.contrib.auth.models import User

from django.core.files.storage import FileSystemStorage


def Pruebas(request):
	print('--------------------------->>    ',time.strftime("%A"),'/',time.strftime("%B"))
	return render(request,'usuario.html')





from django.db import connection
def usuario(request):
	dicc={}

	#===============noticia===========
	lst_not=Noticia.objects.filter(estado='Publicada').order_by('-pk')
	dicc['pk_max']=0
	for x in lst_not:
		if x.pk > dicc['pk_max']:
			dicc['pk_max']= x.pk
	dicc['lst_noticias']=lst_not

	# ===========caudal===================
	cau=Caudal.objects.all().order_by("fecha")
	p=0
	for x in cau:
		p+=1
	cant_cau=cau.count()
	dicc['fecha']=datetime.datetime.now()
	dicc['caudales']=cau
	dicc['cant_cau']=cant_cau

	
	# ===========rep_reparto==============
	cursor = connection.cursor()
	cursor.execute("CALL sp_cant_por_reparto")
	result = []
	detalles = cursor.fetchall()
	for row in detalles:
	        dic = dict(zip([col[0] for col in cursor.description], row))				
	        result.append(dic)
	cursor.close()
	dicc['repartos']=result
	
	return render(request,'usuario.html',dicc)
 




class PerfilEditar(UpdateView):
	model=AuthUser
	form_class=AuthUserForm
	template_name='usuario/perfil_editar.html'
	success_url=reverse_lazy('usuario')




class ApiTraerParc(View):

	def get(self, request, *args, **kwargs):
		userpk = self.request.GET.get('userpk')
		rpta ="Err"
		if userpk != "":
			if Parcela.objects.filter(id_auth_user=userpk).exists():
				pr=Parcela.objects.filter(id_auth_user=userpk)
				rpta='{'
				cont=0
				for p in pr:
					if cont == 0:
						rpta+='"'+str(cont)+'":"'+p.nombre+'"'
					else:
						rpta+=',"'+str(cont)+'":"'+p.nombre+'"'
					cont+=1
				rpta+='}'			
		return HttpResponse(rpta)

		

class ApiTraerOrd(View):

	def get(self, request, *args, **kwargs):
		userpk = self.request.GET.get('userpk')
		rpta ="Err"
		if userpk != "":
			if OrdenRiego.objects.filter(id_parcela__id_auth_user=userpk).exists():
				pr=OrdenRiego.objects.filter(id_parcela__id_auth_user=userpk).order_by('-fecha_inicio')
				rpta='{'
				cont=0
				fechaa = "sin fecha"
				for p in pr:
					if p.fecha_inicio != None:
						fechaa = " "+str(p.fecha_inicio.day)+'/'+str(p.fecha_inicio.month)+'/'+str(p.fecha_inicio.year)+' - H: '
						fechaa += str(p.fecha_inicio.hour)+':'+str(p.fecha_inicio.minute)

					if cont == 0:
						rpta+='"'+str(cont)+('":" F: '+fechaa+'_ Est:  '+ p.estado+'"')
					else:
						rpta+=',"'+str(cont)+('":" F: '+fechaa+'_ Est:  '+ p.estado+'"')
					cont+=1
				rpta+='}'		
		return HttpResponse(rpta)

class ApiAsamb(View):
		
	def get(self, request, *args, **kwargs):
		userpk = self.request.GET.get('userpk')
		rpta ="Err"

		if Asamblea.objects.filter(estado=1).exists():
			lsta=Asamblea.objects.filter(estado=1)
			rpta='{'
			cant=0
			for a in lsta:
				if cant == 0:
					rpta+='"0":" tipo: '+a.tipo+', el '+str(a.fecha_asamblea.day)+'/'+str(a.fecha_asamblea.month)+'/'+str(a.fecha_asamblea.year)+'_'+str(a.fecha_asamblea.hour)+':'+str(a.fecha_asamblea.minute)+'"'
				else:
					rpta+=',"'+cant+'":" tipo: '+a.tipo+', el '+str(a.fecha_asamblea.day)+'/'+str(a.fecha_asamblea.month)+'/'+str(a.fecha_asamblea.year)+'_'+str(a.fecha_asamblea.hour)+':'+str(a.fecha_asamblea.minute)+'"'
				cant+=1
			rpta+='}'

			
		return HttpResponse(rpta)

 

class ApiTraerMul(View):

	def get(self, request, *args, **kwargs):
		userpk = self.request.GET.get('userpk')
		rpta ='{"cant":'
		cant=0
		if MultaOrden.objects.filter(id_orden__id_parcela__id_auth_user=userpk).exists():
			lmo=MultaOrden.objects.filter(id_orden__id_parcela__id_auth_user=userpk)
			cant+=lmo.count()

		if MultaAsistencia.objects.filter(id_hoja_asistencia__id_auth_user=userpk).exists():
			lma=MultaAsistencia.objects.filter(id_hoja_asistencia__id_auth_user=userpk)
			cant+=lma.count()

		if MultaLimpia.objects.filter(id_det_limpia__id_destajo__id_parcela__id_auth_user=userpk).exists():
			lmd=MultaLimpia.objects.filter(id_det_limpia__id_destajo__id_parcela__id_auth_user=userpk)
			cant+=lmd.count()

		rpta+=str(cant)+'}'

		return HttpResponse(rpta)


class ApiTraerPerf(View):

	def get(self, request, *args, **kwargs):
		userpk = self.request.GET.get('userpk')
		rpta ="Err"
		if userpk != "":
			if AuthUser.objects.get(pk=userpk).foto:
				#print("  >> Si tiene foto: ["+str(AuthUser.objects.get(pk=userpk).foto)+"]")
				rpta=str(AuthUser.objects.get(pk=userpk).foto)
			else:
				rpta="Inv"
				#print("  >> No tiene foto")		
		return HttpResponse(rpta)
		

class ApiContra(View):

	def get(self, request, *args, **kwargs):
		userpk = self.request.GET.get('userpk')
		ncon = self.request.GET.get('ncon')
		rpta="Err"
		from django.contrib.auth.models import User
		if AuthUser.objects.filter(pk=userpk).exists():
			u = User.objects.get(pk=userpk)
			u.set_password(ncon)
			u.save()
			rpta="Ok"	
		return HttpResponse(rpta)
		
		
class ApiEdiSx(View):

	def get(self, request, *args, **kwargs):
		userpk = self.request.GET.get('userpk')
		sx = self.request.GET.get('sx')
		rpta="Err"
		if AuthUser.objects.filter(pk=userpk).exists():
			AuthUser.objects.filter(pk=userpk).update(sexo=sx)
			rpta="Ok"	
		return HttpResponse(rpta)


class ApiEdiFn(View):

	def get(self, request, *args, **kwargs):
		userpk = self.request.GET.get('userpk')
		fn = self.request.GET.get('fn')
		rpta="Err"
		if AuthUser.objects.filter(pk=userpk).exists():
			AuthUser.objects.filter(pk=userpk).update(fecha_nacimiento=fn)
			rpta="Ok"	
		return HttpResponse(rpta)












 

class FiltrarParcelas(ListView):
    model = Parcela
    template_name = 'parcela/u_misparcelas_lis.html'

    def get_queryset(self):
        queryset = super(FiltrarParcelas, self).get_queryset()
        idauth = self.request.GET.get('id_auth')
        queryset = Parcela.objects.filter(id_auth_user=idauth)
        return queryset



class MisOrdenes(ListView):
    model = Parcela
    template_name = 'orden/u_mis_ordenes_lis.html'

    def get_queryset(self):
        queryset = super(MisOrdenes, self).get_queryset()
        idauth = self.request.GET.get('id_auth')
        queryset = OrdenRiego.objects.filter(id_parcela__id_auth_user=idauth).order_by('-pk')
        return queryset



class VerRepartos(View):

	def get(self, request, *args, **kwargs):
		from django.db import connection	
		cursor = connection.cursor()
		cursor.execute("CALL sp_rep_disponibles")
		result = []
		detalles = cursor.fetchall()
		for row in detalles:
		        dic = dict(zip([col[0] for col in cursor.description], row))				
		        result.append(dic)
		cursor.close()
		diccionario={}
		diccionario['object_list']=result
		for d in result:
			print('   - -  - >',d)
		return render(request,'reparto/u_reparto_lis.html',diccionario)


class EliOrden(UpdateView):
	model=OrdenRiego
	form_class=OrdenRForm
	template_name='orden/u_orden_eli.html'
	success_url=reverse_lazy('usuario')

	

class SolOrdenList(TemplateView):

	def get(self, request, *args, **kwargs):
		idauth = self.request.GET.get('id_auth')
		idrepa = self.request.GET.get('id_repa')
		parcelas=Parcela.objects.filter(id_auth_user=idauth)
		reparto =Reparto.objects.get(id_reparto=idrepa)
		return render(request,'orden/u_orden_sol.html',{'parcelas':parcelas,'reparto':reparto})

	def post(self, request, *args, **kwargs):
		id_repa = self.request.POST.get('id_repa')
		id_par = self.request.POST.get('id_parcela')
		cantidad = self.request.POST.get('cantidad')
		id_au = self.request.POST.get('id_auth')
		importes = (float(cantidad)*2.5)
		us=AuthUser.objects.get(id=id_au)

		parcelas=Parcela.objects.filter(id_auth_user=us)
		reparto =Reparto.objects.get(id_reparto=id_repa)

		validador = {}
		validador['hecho']=False
		validador['parcelas'] = parcelas
		validador['reparto'] = reparto
		if float(cantidad) <= 0:
			validador['mensaje'] = 'Ingrese horas correctas!'
			return render(request,'orden/u_orden_sol.html',validador)
		else: 
			id_r=Reparto.objects.get(id_reparto=int(id_repa))
			id_p=Parcela.objects.get(id_parcela=int(id_par))
			ver_ord=OrdenRiego.objects.filter(id_reparto=id_r,id_parcela=id_p)
			if ver_ord:
				validador['hecho'] = True
				validador['mensaje'] = 'Usted ya ha sacado una orden para esa parcela en este reparto!'
			else:
				t=datetime.datetime.now()
				ori=OrdenRiego(id_reparto=id_r,	id_parcela=id_p,duracion=float(cantidad),
				cantidad_has=float(cantidad),unidad='h',estado='Solicitada',
				fecha_establecida=t,importe=importes)
				ori.save()			
				validador['hecho'] = True
				validador['mensaje'] = 'Orden registrada con éxito'
		return render(request,'orden/u_orden_sol.html',validador)



class NoticiaList(ListView):
	model=Noticia
	template_name='noticia/u_noticia_lis.html'

	def get(self, request, *args, **kwargs):
		dicc = {}
		dicc['object_list']=Noticia.objects.filter(estado="Publicada").order_by('-pk')
		return render(request, self.template_name,dicc)


class OrdenDelete(DeleteView):
	model=OrdenRiego
	form_class=OrdenRForm
	template_name='orden/u_orden_eli.html'
	success_url=reverse_lazy('u_orden_lis')

 
class OrdenList(ListView):
	model=OrdenRiego
	template_name='orden/u_orden_lis.html'
	paginate_by=10





class UsuarioDelete(DeleteView):
	model=DatosPersonales
	form_class=PersonaForm
	template_name='usuario/borrar_usuario.html'
	success_url=reverse_lazy('listar')

class UsuarioUpdate(UpdateView):
	model=DatosPersonales
	form_class=PersonaForm
	template_name='usuario/crear_usuario.html'
	success_url=reverse_lazy('listar') 

class UsuarioCreate(CreateView):
	model=DatosPersonales
	form_class=PersonaForm
	template_name='usuario/crear_usuario.html'
	success_url=reverse_lazy('listar')

class UsuarioList(ListView):
	model=DatosPersonales
	template_name='usuario/lista_usuarios.html'
	paginate_by=10




class AsambLst(View):

	def get(self,request,*args,**kwargs):
		dicc={}
		if Asamblea.objects.filter(estado=2).exists():
			dicc['object_list']=Asamblea.objects.filter(estado=2).order_by('-pk')			
		return render(request,"asamblea/lst_asamblea.html",dicc)
		
class AsambDet(View):

	def get(self,request,*args,**kwargs):
		apk=self.request.GET.get("apk")
		dicc={}
		if Asamblea.objects.filter(pk=apk).exists():
			dicc['object_list']=Asamblea.objects.get(pk=apk)

		if Asamblea.objects.filter(estado=2).exists():
			dicc['agenda']=AgendaAsamblea.objects.filter(id_asamblea=apk).order_by('-pk')
			
		return render(request,"asamblea/asamblea_det.html",dicc)
		

## ======================= 	LstDestajos ============================


class LstDestajos(View):
	def get(self,request,*args,**kwargs):
		userpk=self.request.GET.get("userpk")
		dicc={}
		if Destajo.objects.filter(id_parcela__id_auth_user=userpk).exists():
			dicc['lst_dstjs']=Destajo.objects.filter(id_parcela__id_auth_user=userpk).order_by('id_canal','num_orden')
			
		return render(request,"destajo/lst_dstjs.html",dicc)
 




class LstMultas(View):

	def get(self, request, *args, **kwargs):
		userpk = self.request.GET.get('userpk')
		dicc={}		
		if MultaOrden.objects.filter(id_orden__id_parcela__id_auth_user=userpk).exists():
			dicc['lst_ord']=MultaOrden.objects.filter(id_orden__id_parcela__id_auth_user=userpk)

		if MultaAsistencia.objects.filter(id_hoja_asistencia__id_auth_user=userpk).exists():
			dicc['lst_asi']=MultaAsistencia.objects.filter(id_hoja_asistencia__id_auth_user=userpk)

		if MultaLimpia.objects.filter(id_det_limpia__id_destajo__id_parcela__id_auth_user=userpk).exists():
			dicc['lst_des']=MultaLimpia.objects.filter(id_det_limpia__id_destajo__id_parcela__id_auth_user=userpk)

		return render(request,"multa/mul_lst.html",dicc)


class ApiOrd(View):

	def get(self, request, *args, **kwargs):
		ordpk=self.request.GET.get("ordpk")		
		estado=self.request.GET.get("estado")
		#print("  >> ordpk: "+str(ordpk)+"  >> std: "+estado)
		OrdenRiego.objects.filter(pk=ordpk).update(estado=estado)
		return HttpResponse("Ok")
	


class ApiQr(View):

	def get(self, request, *args, **kwargs):
		userpk=self.request.GET.get("userpk")	
		rpta = "Ok"
		if userpk == '1':
			if OrdenRiego.objects.filter(estado='Iniciada').exists():
				enr=OrdenRiego.objects.filter(estado='Iniciada')
				rpta='{'
				cont=0
				for x in enr:
					if cont==0:
						rpta+='"0":" En el '+x.id_parcela.id_canal.nombre+' está regando '+x.id_parcela.id_auth_user.first_name+' '+x.id_parcela.id_auth_user.last_name+' en la toma '+ str(x.id_parcela.num_toma)+'"'
					else:
						rpta+=',"'+str(cont)+'":" En el '+x.id_parcela.id_canal.nombre+' está regando '+x.id_parcela.id_auth_user.first_name+' '+x.id_parcela.id_auth_user.last_name+' en la toma '+ str(x.id_parcela.num_toma)+'"'
					cont+=1
				rpta+='}'
			else:
				rpta="Err"
			
		return HttpResponse(rpta)

"""
class ApiGraf1(View):

	def get(self, request, *args, **kwargs):
		userpk=self.request.GET.get("userpk")	
		# ===========caudal===================
		json = "{"	
		cau=Caudal.objects.all().order_by("fecha")
		json+='"0":"'+str(cau.count())+'","1":"'+str(datetime.datetime.now())+'"'
		cont=2
		for x in cau:
			json+=',"'+str(cont)+'":"'+str(x.fecha.day)+'/'+str(x.fecha.month)+'/'+str(x.fecha.year)+'"'
			cont+=1


		cont = 50
		for x in cau:
			json+=',"'+str(cont)+'":"'+str(x.nivel)+'"'
			cont+=1

		json += '}'			
		return HttpResponse(json)

"""

"""

		# ===========caudal===================
		cau=Caudal.objects.all().order_by("fecha")
		p=0
		for x in cau:
			p+=1
		cant_cau=cau.count()
		dicc['fecha']=datetime.datetime.now()
		dicc['caudales']=cau
		dicc['cant_cau']=cant_cau

		rpta = json.dumps(cau)

		#print("   json: "+json.dumps(cau))
"""
from django.shortcuts import render, redirect
from apps.inicio.models import DatosPersonales, OrdenRiego, Noticia, Parcela, AuthUser, Reparto, AuthUser, Caudal
from apps.inicio.forms import PersonaForm
from apps.usuario.forms import OrdenRForm


from django.urls import reverse_lazy
from django.views.generic import ListView, CreateView,UpdateView,DeleteView, TemplateView, View


import datetime
import time


from django.contrib.auth.models import User

def Pruebas(request):
	print('--------------------------->>    ',time.strftime("%A"),'/',time.strftime("%B"))
	return render(request,'usuario.html')



def usuario(request):
	dicc={}

	#===============noticia===========
	dicc['lst_noticias']=Noticia.objects.all().order_by('-pk')

	# ===========caudal==============
	cau=Caudal.objects.all().order_by("fecha")
	cant_cau=cau.count()
	dicc['fecha']=datetime.datetime.now()
	dicc['caudales']=cau
	dicc['cant_cau']=cant_cau
	return render(request, 'usuario.html',dicc)
 

 

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
		from django.db import connection, transaction	
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
	paginate_by=9




class OrdenDelete(DeleteView):
	model=OrdenRiego
	form_class=OrdenRForm
	template_name='orden/u_orden_eli.html'
	success_url=reverse_lazy('u_orden_lis')

class OrdenUpdate(UpdateView):
	model=OrdenRiego
	form_class=OrdenRForm
	template_name='orden/u_orden_reg.html'
	success_url=reverse_lazy('u_orden_lis') 

class OrdenCreate(CreateView):
	model=OrdenRiego
	form_class=OrdenRForm
	template_name='orden/u_orden_reg.html'
	success_url=reverse_lazy('u_orden_lis')

class OrdenList(ListView):
	model=OrdenRiego
	template_name='orden/u_orden_lis.html'
	paginate_by=10





class UsuarioDelete(DeleteView):
	model=DatosPersonales
	form_class=PersonaForm
	template_name='borrar_usuario.html'
	success_url=reverse_lazy('listar')

class UsuarioUpdate(UpdateView):
	model=DatosPersonales
	form_class=PersonaForm
	template_name='crear_usuario.html'
	success_url=reverse_lazy('listar') 

class UsuarioCreate(CreateView):
	model=DatosPersonales
	form_class=PersonaForm
	template_name='crear_usuario.html'
	success_url=reverse_lazy('listar')

class UsuarioList(ListView):
	model=DatosPersonales
	template_name='lista_usuarios.html'
	paginate_by=10




"""

class UsuarioList(ListView):
	model=Persona
	template_name='lista_usuarios.html'



def edirtar_usuario(request,id_usuario):
	usuario=Usuario.objects.get(id=id_usuario)
	if request.method == "GET":
		form=PersonaForm(instance=usuario)
	else:
		form = PersonaForm(request.POST,instance=usuario)
		if form.is_valid():
			form.save()
			return redirect('UsuarioList')
	return render(request,'crear_usuario.html', {'form':form})



def registrar_usuario(request):	
	if request.method == 'POST':
		form = UsuarioForm(request.POST)
		if form.is_valid():
			form.save() 
		return redirect('lista_usuarios')

	else:
		form=UsuarioForm()
	return render(request,'registrar_usuario.html',{'form':form})



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


def eliminar_usuario(request,id_usuario):
	usuario=Usuario.objects.get(id=id_usuario)
	if request.method == "POST":
		usuario.delete()
		return redirect('lista_usuarios')
	return render(request,'eliminar_usuario.html', {'usuario':usuario})



class OrdenList(ListView):
	model=Orden
	template_name='listar_ordenes.html'



class OrdenCreate(CreateView):
	model = Orden
	form_class=OrdenForm
	template_name='crear_orden.html'
	success_url=reverse_lazy('OrdenList')



class UsuarioCreate(CreateView):
	model = Usuario
	form_class = UsuarioForm
	template_name='registrar_usuario.html'
	success_url =  reverse_lazy('lista_usuarios')


class UsuarioUpdate(UpdateView):
	model = Usuario
	form_class = UsuarioForm
	template_name='registrar_usuario.html'
	success_url =  reverse_lazy('lista_usuarios')

class UsuarioDelete(DeleteView):
	model=Usuario 
	template_name='eliminar_usuario.html'
	success_url =  reverse_lazy('lista_usuarios')

"""



"""
class ListadoCompleto(ListView):
    model = Parcela
    template_name = "usuario_parcela.html"

class RegistroCompleto(CreateView):
    model = Percela
    template_name = "usuario_parcela.html"
    form_class= ParcelaForm
    second_form_class=UsuarioForm
    success_url=reverse_lazy('usuario_parcela.html')

	def get_context_data(self, **kwargs):
	    context = super(RegistroCompleto, self).get_context_data(**kwargs)
	    if 'form' not in context:
	    	context['form']=self.form_class(self.request.GET)
	    if 'form2' not in context:
	    	context['form2']=self.second_form_class(self.request.GET)
	    return context

	 def post(self, request, *args, **kwargs):
	 	self.objects=self.get_object
	 	form = sel.form_class(request.POST)
	 	form2 = sel.second_form_class(request.POST)
	 	if form is_valid() and form2 is_valid():
	 		parcela=form.save(commit=False)
	 		parcela.Usuario=form2.save()
	 		parcela.save()
	 		return HttpResponseRedirect(self.get_success_url())


"""





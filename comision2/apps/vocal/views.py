from django.shortcuts import render
from django.contrib.auth.decorators import login_required, permission_required
from django.views.generic import ListView, CreateView,UpdateView,DeleteView, TemplateView, View
from apps.inicio.models import *
from django.http import HttpResponse

# Create your views here.

@permission_required('inicio.es_vocal')
def vocal(request):
	return render(request, 'vocal.html')



class AsmbList(View):

	def get(self, request, *args, **kwargs):
		asmb= Asamblea.objects.all().order_by('-id_asamblea');
		return render(request,'asamblea/v_asmb_lis.html',{'Asambleas':asmb})

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
		return render(request,'p_act_usu.html',dicc)



from django.db.models import Q
class HasisGen(View):
	

	def get(self, request, *args, **kwargs):
		pk_asmb = self.request.GET.get("id_asmb")
		tipo_asmb = self.request.GET.get("tipo_asmb")
		#print("  >> id_asmb: "+pk_asmb+"  > t: "+tipo_asmb);
		cont = 0
		asmbl=Asamblea.objects.get(pk=pk_asmb)

		if tipo_asmb == "General":
			parc = Parcela.objects.all()
			for p in parc :
				if HojaAsistencia.objects.filter(Q(id_asamblea=pk_asmb) & Q(id_auth_user=p.id_auth_user)).exists():
					cont +=1
					#print("     ------ya está 0")
					#ff = HojaAsistencia.objects.filter(Q(id_asamblea=pk_asmb) & Q(id_auth_user=p.id_auth_user))
					#for x in ff:
					#	print("        > "+str(x.id_auth_user))
				else:
					#print("  >> no está : "+str(p.id_auth_user)+" -->"+pk_asmb)
					Hasis = HojaAsistencia(id_asamblea=asmbl,id_auth_user=p.id_auth_user,estado="0",hora="2000-12-12 12:00:00")
					Hasis.save()
			#print("se creó la asamblea y su hoja de asistencia.")
		elif tipo_asmb == "Simple":
			detc = DetAsambCanal.objects.filter(id_asamblea=pk_asmb)
			for x in detc:
				parc=Parcela.objects.filter(id_canal=x.id_canal)
				for p in parc :
					if HojaAsistencia.objects.filter(Q(id_asamblea=pk_asmb) & Q(id_auth_user=p.id_auth_user)).exists():
						#print("     ------ya está 0")
						#ff = HojaAsistencia.objects.filter(Q(id_asamblea=pk_asmb) & Q(id_auth_user=p.id_auth_user))
						#for x in ff:
						#	print("        > "+str(x.id_auth_user))
						cont +=1
					else:
						#print("  >> no está : "+str(p.id_auth_user)+" -->"+pk_asmb)
						Hasis = HojaAsistencia(id_asamblea=asmbl,id_auth_user=p.id_auth_user,estado="0",hora="2000-12-12 12:00:00")
						Hasis.save()

			print(">>Se creó la hoja de asistencia [rep:"+str(cont)+"].")

		return render(request,'asamblea/p_asamb_reg.html',{'msj':'Se guardó correctamente.'})


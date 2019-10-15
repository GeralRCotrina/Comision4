from django import forms
from django.contrib.auth.models import User
from django.contrib.auth.forms import UserCreationForm
from apps.inicio.models import Parcela, Canal, Noticia, Caudal, AuthUser, Asamblea



class NoticiaForm(forms.ModelForm):

	class Meta:
		model = Noticia

		fields = ['id_noticia','titular','titulo','descripcion','fecha','foto']	
		labels = {
			'titular':'Titular',
			'titulo':'Titulo',
			'descripcion':'Descripción',
			'fecha':'Fecha',
			'foto':'foto',
		}

		widgets={
		    'titular':forms.TextInput(attrs={'class':'form-control'}),
		    'titulo':forms.TextInput(attrs={'class':'form-control'}),
		    'descripcion':forms.Textarea(attrs={'class':'form-control'}),
		    'fecha':forms.DateTimeInput(attrs={'class':'form-control','type':'date',}),
		    'foto':forms.FileInput(attrs={'class':'btn-block'}),
		    }


class RegistroForm(UserCreationForm):

	class Meta:
		model = User
		fields=['id', 'username', 'first_name', 'last_name', 'email', ]

		labels={
			'id':'Referencia',
			'username':'Nombre de acceso',
			'first_name':'Nombres',
			'last_name':'Apellidos',
			'email':'Correo',
		}
		

class ParcelaForm(forms.ModelForm):

	class Meta:
		model = Parcela

		fields = ['id_parcela','id_canal','id_auth_user','num_toma','nombre','codigo_predio',
				'ubicacion','total_has','has_sembradas','descripcion',
			    'estado','volumen_agua']

		labels = {
			'nombre':'Nombre de la Parcela (*)',
			'codigo_predio':'Codigo del predio (*)',
			'ubicacion':'Descripción de ubicación (*)',
			'num_toma':'N° de Toma en el canal (*)',
			'id_canal':'Canal en el que se encuentra (*)',
			'id_auth_user':'Actual Propietario (*)',
			'total_has':'Cantidad de hectáreas (*)',
			'has_sembradas':'Cantidad de Has Sembradas (*)',
			'descripcion':'Breve descripción.',
			'estado':'Estado actual de la parcela (*)',
			'volumen_agua':'Volumen de agua',
		}

		widgets={	
			    'nombre':forms.TextInput(attrs={'class':'form-control','required':'required'}),
			    'codigo_predio':forms.TextInput(attrs={'class':'form-control','required':'required'}),
			    'ubicacion':forms.TextInput(attrs={'class':'form-control','required':'required','row':'2'}),
			    'num_toma':forms.TextInput(attrs={'class':'form-control','required':'required','min':'1'}),
			    'id_canal':forms.Select(attrs={'class':'form-control','required':'required'}),
			    'id_auth_user':forms.Select(attrs={'class':'form-control','required':'required'}),
			    'total_has':forms.TextInput(attrs={'class':'form-control','required':'required'}),
			    'has_sembradas':forms.TextInput(attrs={'class':'form-control','required':'required'}),
			    'descripcion':forms.TextInput(attrs={'class':'form-control'}),
			    'estado':forms.Select(attrs={'class':'form-control','placeholder':'No olvide poner "Activa"','required':'required'}),
			    'volumen_agua':forms.TextInput(attrs={'class':'form-control'}),
		    }


class CaudalForm(forms.ModelForm):

	class Meta:
		model = Caudal
		fields=['id_caudal','id_canal','fecha','nivel','descripcion',]

		labels={
			'id_canal':'Canal',
			'nivel':'Nivel de agua',
			'descripcion':'descripcion',
		}
		widgets={	
				'id_canal':forms.Select(attrs={'class':'form-control'}),
			    'nivel':forms.TextInput(attrs={'class':'form-control'}),
			    'descripcion':forms.TextInput(attrs={'class':'form-control'}),
		    }


class CanalForm(forms.ModelForm):

	class Meta:
		model = Canal

		fields = ['id_canal','nombre','tamano','ubicacion',]	

		labels = {
			'id_canal':'Clave del canal',
			'nombre':'Nombre del Canal',
			'tamano':'Tamaño',
			'ubicacion':'Ubicación',
		}

		widgets={	
				'id_canal':forms.TextInput(attrs={'class':'form-control'}),
			    'nombre':forms.TextInput(attrs={'class':'form-control'}),
			    'tamano':forms.TextInput(attrs={'class':'form-control'}),
			    'ubicacion':forms.TextInput(attrs={'class':'form-control'}),
		    }




class AuthForm(forms.ModelForm):

	class Meta:
		model = AuthUser

		fields = ['username','first_name','last_name','email','dni','sexo',
		    'alias','fecha_nacimiento','telefono','celular']

		labels = {
			'first_name':'Nombres (*)',
			'last_name':'Apellidos (*)',
			'username':'Nombre de acceso (*) (sin espacios)',
			'dni':'N° de DNI (*)',
			'email':'Correo @',
			'alias':'alias',
			'sexo':'Sexo',
			'fecha_nacimiento':'fecha nacimiento',
			'telefono':'telefono',
			'celular':'Movil',
			}

		widgets={	
			    'username':forms.TextInput(attrs={'class':'form-control col-7','required':'required'}),
			    'first_name':forms.TextInput(attrs={'class':'form-control','required':'required'}),
			    'last_name':forms.TextInput(attrs={'class':'form-control','required':'required'}),
			    'email':forms.TextInput(attrs={'class':'form-control'}),
			    'dni':forms.TextInput(attrs={'class':'form-control col-7','type':'number','required':'required'}),
			    'alias':forms.TextInput(attrs={'class':'form-control col-7'}),
				'sexo':forms.Select(attrs={'class':'form-control col-7'}),
				'fecha_nacimiento':forms.DateInput(attrs={'class':'form-control col-7','type':'date'}),
				'telefono':forms.TextInput(attrs={'class':'form-control col-7'}),
				'celular':forms.TextInput(attrs={'class':'form-control col-7'}),
		    }

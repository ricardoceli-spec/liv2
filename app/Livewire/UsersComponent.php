<?php

namespace App\Livewire;
use App\Models\User;
use Livewire\Component;

class UsersComponent extends Component
{
    public $title;
    public $name;
    public $email;
    public $password;

    
    public function crearUsuario()
    {
        $this->validate([
            "name"=>"required",
            "email"=>"required|unique:users,email",
            "password"=>"required"
        ]);

        User::create([
            "name"=>$this->name,
            "email"=>$this->email,
            "password"=>$this->password
        ]);
        //dump("click");
    }
    public function click()
    {
        dump("click");
    }

    public function render()
    {
        $this->title = "Usuarios";
        $UserCount = User::count();
        $users = User::all();

        return view('livewire.users-component',[
            "title"=>$this->title,
            "UserCount"=>$UserCount,
            "users"=>$users
        ]);
    }
}

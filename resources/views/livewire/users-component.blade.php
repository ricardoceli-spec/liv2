<div>
    {{-- A good traveler has no fixed plans and is not intent upon arriving. --}}
    <h1>Usuarios</h1>
    <h1>{{ $title }} {{ $UserCount }}</h1>
    <button wire:click="click">Click dump</button>

    <!-- <button wire:click="crearUsuario">Crear usuario</button> -->
    <br><br>

    <form wire:submit="crearUsuario">
        <input wire:model="name" type="text" placeholder="Nombre"> 
            @error("name") {{ $message }} @enderror <br>
        <input wire:model="email" type="email" placeholder="Email">
             @error("email") {{ $message }} @enderror <br>
        <input wire:model="password" type="password" placeholder="Contraseña">
             @error("password") {{ $message }} @enderror <br>
        <br>
        <button>Crear usuario</button>
    </form>
    <br>

    <ul>
        @foreach ($users as $user)
           <li>{{ $user->name }}</li> 
        @endforeach
    </ul>


    
</div>

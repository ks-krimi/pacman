/**
* Name: pacman
* This is a model to simulate a Pacman game, my favorite game when i was a kid 
* Author: FANOMEZANTSOA Herifiandry Marc Nico
* Email: ny.kalash@gmail.com
* Tags: game, pacman, childwood game
*/


model pacman

global {
	
	string my_name <- "Nico";
	int my_age <- 25;
	bool is_male <- true;
	float my_size <- 1.80#m;
	string my_default <- nil;
	
	list<int> favoriteNumb <- [1,8,4,9] where(each <= 8);
	string fruits <- "avocat" among: ["mango","orange", "avocat"];
	
	reflex write_in_console {
		write my_name;
		write my_age;
		write is_male;
		write my_size;
		write my_default;
	}
	
	reflex print {
		loop i over: favoriteNumb {
			write i;
		}
	}
	
	reflex plot {
		loop i from: 0 to: 10 step: 2 {
			write i;
		}
	}
	
}

species ghost {
	
}

species pacman {
	
}

experiment run type:gui {
	
	output {
		
	}
	
}

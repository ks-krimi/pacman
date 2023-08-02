/**
* Name: pacman
* This is a model to simulate a Pacman game, my favorite game when i was a kid 
* Author: FANOMEZANTSOA Herifiandry Marc Nico
* Email: ny.kalash@gmail.com
* Tags: game, pacman, childwood game
*/

model pacman

/**
 * if facet torus: true
 * the agent going out of env will appear on the other side
*/
global torus: true {
	int balloon_create <- 0;
	int balloon_dead <- 0;
	
	// geometry shape <- square(100#m);

	reflex name: create_balloon when: flip(0.1) {
		if (balloon_create < 10){
			create Balloon number: 1;
			balloon_create <- balloon_create + 1;
		}
	}
	
	reflex name: end_simulation when: balloon_dead >= 10 {
		ask host {
			do die;
		}
	}
}

species Balloon {
	float balloon_size;
	rgb balloon_color;
	
	init {
		balloon_size  <- 0.1;
		balloon_color <- rgb(rnd(255), rnd(255), rnd(255));
	}
	
	aspect balloon_aspect {
		draw circle(balloon_size#m) color: balloon_color;
		draw string("size: " + round(balloon_size)) color: #grey;
	}
	
	action destroy {
		balloon_dead <- balloon_dead + 1;
		write "Nombre de balloon detruit: " + balloon_dead ;
		do die;
	}
	
	reflex grow {
		balloon_size <- balloon_size + 0.1#m;
	}

	reflex getold when: balloon_size >= 10#m {
		do destroy;
	}
}

experiment Run type: gui {

    output {
        display "Game Evironement" {
           species Balloon aspect: balloon_aspect;
        }
    }

}

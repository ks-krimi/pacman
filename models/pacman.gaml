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
	
	geometry shape <- rectangle(250#cm, 250#cm);
	
	init {
		create Pacman number:1;
		create Ghost number: 3;
	}
}

species name:Ghost {
	init {
		name <- "Red Ghost";
		shape <- circle(5#cm);
	}
	
	aspect name:red {
		draw shape color: #red;
	}
}

species Pacman {
	init {
		name <- "Pacman";
		shape <- circle(8#cm);
	}
	aspect yellow {
		draw shape color: #yellow;
	}
}

experiment Run type: gui {
    output{
        display "Game Evironement" {
            species Ghost aspect:red;
            species Pacman aspect:yellow;
        }
    }
}
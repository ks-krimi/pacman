model Pacman

global torus: true {
	init {
		create Pacman number: 1;
		create Ghost number: 3;
	}
}

species name: Ghost skills: [moving] {
	Pacman pacman;
	init {
		speed <- 0.5;
		heading <- 50.0;
	}
	aspect name: Angry {
		draw circle(1) color: #red;
	}
	reflex name: find_pacman when: pacman=nil {
		ask Pacman {
			myself.pacman <- self;
		}
	}
	reflex name: follow_pacman when: pacman!=nil {
		do goto target: pacman;
	}
}

species name: Pacman skills: [moving] {
	init {
		speed <- 1.0;
		heading <- 90.0;
	}
	aspect name: Yellow {
		draw circle(1.5) color: #yellow;
	}
	reflex name: move {
		do wander amplitude: 90.0;
	}
}

experiment Run type: gui {
	output {
		display "Game World" {
			species Pacman aspect: Yellow;
			species Ghost aspect: Angry;
		}
	}
}

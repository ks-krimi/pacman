model Pacman

global torus: true {
	
	float step <- 2.25#s;
	bool is_pacman_dead <- false;
	bool is_food_overlap;
	
	file data <- csv_file('../includes/world.csv',',');
	
	image_file red_ghost_icon <-  image_file('../includes/redGhost.png');
	image_file blue_ghost_icon <-  image_file('../includes/blueGhost.png');
	image_file green_ghost_icon <-  image_file('../includes/greenGhost.png');
	image_file orange_ghost_icon <-  image_file('../includes/orangeGhost.png');
	
	list<environement> roads;
	list<environement> decors;
	
	list<string> ghost_names <- ["Red", "Blue", "Green", "Orange"];
	list<rgb> ghost_colors <- [#red, #blue, #green, #orange];
	list<image_file> ghost_icons <- [
		red_ghost_icon,
		blue_ghost_icon,
		green_ghost_icon,
		orange_ghost_icon
	];
	
	int number_max_of_pacman <- 1;
	int number_max_of_ghost <- 3;
	
	list<point> ghost_init_locations <- [
		environement[11, 8].location,
		environement[10, 10].location,
		environement[11, 10].location,
		environement[12, 10].location
	];
	
	point pacman_init_location <- environement[11, 16].location;
	
	init {
		matrix data_grid <- matrix(data);
		ask environement {
			grid_value <- float(data_grid[grid_x, grid_y]);
			color <- grid_value = 1 ? #white : rgb(164,180,76);
		}
		
		roads <- environement where (each.grid_value = 1);
		decors <- environement where (each.grid_value = 0);
		
		loop road over: roads {
			create Object number: 1 with: (
				icon: image_file('../includes/road.png'),
				location: road.location
			);
		}
		
		loop decor over: decors {
			
			list<image_file> objects <- 1 among [
				image_file('../includes/tree.png'),
				image_file('../includes/stone.png'),
				image_file('../includes/stone2.png'),
				image_file('../includes/bush.png'),
				image_file('../includes/bush2.png')
			];
			
			create Object number: 1 with: (
				icon: objects[0],
				location: decor.location
			);
		}
		
		do create_food;	
		
		loop position over: ghost_init_locations {
			int index <- ghost_init_locations index_of position;
			create Ghost number: 1 {
				location <- position;
				name <- ghost_names[index];
				color <- ghost_colors[index];
				ghost_icon <- ghost_icons[index];
			}
		}

		loop while: length(Pacman) < number_max_of_pacman {
			create Pacman number: 1 with: (pacman_cell: environement(location));
		}
	}
	
	action create_food {
		create Food with: (location: one_of(roads).location) {
			set location <- location;
		}
	}
	
	reflex new_one when: length(Food) = 0  {
		do create_food;
	}
	
	reflex halting when: empty (Pacman) {
        // ask host {
            do pause;
        // }
    }
}

grid environement width: 23 height: 22 {}

species name: Ghost skills: [moving] {
	Pacman pacman;
	rgb color;
	image_file ghost_icon;
	
	init {
		speed <- 0.7;
	}
	
	aspect name: default {
		draw circle(1.5) color: color;
	}
	
	aspect name: icon {
		draw ghost_icon size: 1.0 * 4.5 ;
	}
	
	reflex name: find_pacman when: pacman=nil {
		ask Pacman {
			myself.pacman <- self;
		}
	}
	
	action follow_pacman {
		if (pacman!=nil) {
			do goto target: pacman on: roads;
		}
	}
	
	reflex when: after(starting_date + 15#s) {
		if (self.name = "Red") {
			do follow_pacman;
		}
	}
	
	reflex when: after(starting_date + 1#mn) {
		if (self.name = "Blue") {
			do follow_pacman;
		}
	}
	
	reflex when: after(starting_date + 2#mn) {
		if (self.name = "Green") {
			do follow_pacman;
		}
	}
	
	reflex when: after(starting_date + 3#mn) {
		if (self.name = "Orange") {
			do follow_pacman;
		}
	}
}

species name: Pacman skills: [moving] {
	Food food;
	Ghost ghost;
	environement pacman_cell;
	image_file pacman_icon <- image_file('../includes/PacMan.png');

	init {
		speed <- 0.7;
		location <- pacman_init_location;
	}

	aspect name: default {
		draw circle(1.5) color: #yellow;
	}
	
	aspect name: icon {
		draw pacman_icon size: 1.0 * 4.5 ;
	}

	reflex name: find_food when: food=nil {
		ask Food {
			myself.food <- self;
		}
	}

	reflex name: move when: food!=nil {
		pacman_cell <- get_location();
		if food overlaps (pacman_cell) {
			is_food_overlap <- true;
		}else{
			is_food_overlap <- false;
		}
		do goto target: food on: roads;
	}

	reflex name: avoid_ghost {
		do move bounds: ghost;
	}
	
	reflex when: !is_pacman_dead {
		do eat;
		do died;
	}
		
	action died {
		list<Ghost> ghosts <- Ghost inside (pacman_cell);
		if(!empty(ghosts)) {
			ask self {
				is_pacman_dead <- true;
				do die;
			}
		}
	}
	
	action eat {
		list<Food> foods <- Food inside (pacman_cell);
		if(!empty(foods)) {
			ask one_of (foods) {
				set myself.food <- nil;
				do die;
			}
		}
	}

	environement get_location {
		return environement({location.x, location.y});
	}
}

species Food {
	image_file food_icon <- image_file('../includes/cherry.png');
	
	aspect default {
		draw circle(1) color: #green;
	}
	aspect icon {
		draw food_icon size: 1.0 * 3.3 ;
	}
}

species Object {
	image_file icon;
	aspect name: default {
		draw icon size: 1.0 * 5;
	}
}

experiment Run type: gui {
	
	bool is_game_start <- true;
	
	init {
		start_sound source: '../includes/sounds/game_start.wav' mode: overwrite repeat: false;
	}
	
	reflex when: is_pacman_dead and is_game_start {
		start_sound source: '../includes/sounds/death_1.wav' mode: overwrite repeat: false;
		is_game_start <- false;
	}
	
	reflex when: is_game_start and after(starting_date + 15#s) {
		start_sound source: '../includes/sounds/siren_1.wav' mode: ignore repeat: true;
	}
	
	reflex when: is_food_overlap {
		start_sound source: '../includes/sounds/eat_ghost.wav' mode: overwrite repeat: false;
	}
	
	output {
		display "Game World" {
			grid environement;
			species Object aspect: default;
			species Food aspect: icon;
			species Pacman aspect: icon;
			species Ghost aspect: icon;
		}
	}
}

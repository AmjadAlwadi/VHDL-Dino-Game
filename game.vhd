library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.ALL;

entity game is
    port (
        clk             : in STD_ULOGIC;
        reset           : in STD_ULOGIC;
        button_pressed  : in STD_ULOGIC;
        vsync_i         : in STD_ULOGIC;
        dino_y          : out unsigned (9 downto 0);
        obstacle_x      : out unsigned (9 downto 0);
        obstacle_1_x    : out unsigned (9 downto 0);
        game_over_o     : out STD_ULOGIC;
        led0_o          : out STD_ULOGIC;
        led1_o          : out STD_ULOGIC;
        led2_o          : out STD_ULOGIC;
        led3_o          : out STD_ULOGIC;
        led4_o          : out STD_ULOGIC;
        led5_o          : out STD_ULOGIC;
        led6_o          : out STD_ULOGIC;
        led7_o          : out STD_ULOGIC

        
    );
end entity;

architecture rtl of game is
    constant screen_width     : unsigned (9 downto 0) := to_unsigned(640, 10);
    constant screen_height    : unsigned (9 downto 0) := to_unsigned(480, 10);

    constant obstacle_width   : unsigned (9 downto 0) := to_unsigned(30, 10);
    constant obstacle_height  : unsigned (9 downto 0) := to_unsigned(60, 10);

    constant dino_width       : unsigned (9 downto 0) := to_unsigned(40, 10);
    constant dino_height      : unsigned (9 downto 0) := to_unsigned(90, 10);
    constant dino_x           : unsigned (9 downto 0) := to_unsigned(40, 10);   -- x position is always constant

    constant ground_level     : unsigned (9 downto 0) := to_unsigned(400, 10);

    constant jump_speed     : unsigned (9 downto 0) := to_unsigned(10, 10);
    constant jump_duration  : unsigned (9 downto 0) := to_unsigned(40, 10);
    
    constant min_distance     : unsigned (9 downto 0) := dino_width + to_unsigned(120, 10);
    
    
    signal dino_y_internal    : unsigned (9 downto 0) := ground_level;
    signal dino_is_jumping    : STD_ULOGIC := '0';
    signal dino_is_falling    : STD_ULOGIC := '0';
    signal dino_jump_limit    : unsigned (9 downto 0) := to_unsigned (220,10);

    signal obstacle_x_internal: unsigned (9 downto 0) := screen_width;
    signal obstacle_1_x_internal: unsigned (9 downto 0) := (others => '0');

    signal collision_internal : STD_ULOGIC := '0';

    signal vsync_prev        : STD_ULOGIC;

    signal game_over         : STD_ULOGIC := '0';

    signal scroll_speed      : unsigned (9 downto 0) := to_unsigned(5, 10);
    signal speed_counter     : unsigned (27 downto 0) := (others => '0'); --overflows after 10s
    signal speed_limit       : unsigned (9 downto 0) := to_unsigned(15, 10);

    signal random_number     : unsigned (7 downto 0) := to_unsigned(1, 8);
    signal random_number_1   : unsigned (7 downto 0) := to_unsigned(2, 8);

    signal score             : unsigned (7 downto 0) := (others => '0');

begin

    sync_proc : process (clk) is
    begin
        if rising_edge(clk) then
            vsync_prev <= vsync_i;
        end if;
    end process;



    game_proc : process (clk) is
    
    begin
    
        if rising_edge(clk) then
        
            random_number <= random_number(6 downto 0) & (random_number(7) xor random_number(4));
            random_number_1 <= random_number_1(6 downto 0) & (random_number_1(7) xor random_number_1(2));
        
            if reset = '1' then
                dino_y_internal <= ground_level;
                dino_is_jumping <= '0';
                dino_is_falling <= '0';
                obstacle_x_internal <= screen_width;
                obstacle_1_x_internal <= screen_width + min_distance + to_unsigned(60, 10); 
                collision_internal <= '0';
                game_over <= '0';
                score <= to_unsigned(0,8);


            else
                
		     -- update positions at vsync
             if (vsync_prev = '1' and vsync_i = '0') then
                
                    -- jump
                    if  dino_is_jumping = '0' then
                    
                        if button_pressed = '1' and dino_y_internal >= ground_level then
                            dino_is_jumping <= '1';
                            dino_is_falling <= '0';
                        else
                            dino_is_jumping <= '0';
                        end if;
                    
                    end if;
                    
    
                    if dino_is_jumping = '1' then

                        if dino_is_falling = '0' then

                            if dino_y_internal >= dino_jump_limit then
                                dino_y_internal <= dino_y_internal - jump_speed;
                            else
                                dino_is_falling <= '1';
                            end if;

                        else

                            if dino_y_internal < ground_level then
                                dino_y_internal <= dino_y_internal + jump_speed;
                            else
                                dino_is_falling <= '0';
                                dino_is_jumping <= '0';
                            end if;

                        end if;

                    end if;
    
    
                    speed_counter <= speed_counter + 1;
                    
                    if speed_counter = 0 then
                        if scroll_speed < speed_limit then
                            scroll_speed <= scroll_speed + 2;
                        end if;
                    end if;


                    

                    -- moving the obstacle
                    if obstacle_x_internal > 0 and game_over = '0' then
                        obstacle_x_internal <= obstacle_x_internal - scroll_speed;
                    else
                        obstacle_x_internal <= screen_width + random_number;
                        score <= score + to_unsigned(1,8);
                    end if;
    

                    if obstacle_1_x_internal > 0 and game_over = '0' then
                        obstacle_1_x_internal <= obstacle_1_x_internal - scroll_speed;
                    else
                        obstacle_1_x_internal <= obstacle_x_internal + min_distance + random_number_1;
                        score <= score + to_unsigned(1,8);
                    end if;
    
    
                    -- collision 
                    if (obstacle_x_internal <= dino_x + dino_width) and 
                       ((obstacle_x_internal + obstacle_width) > dino_x) and
                       (dino_y_internal >= ground_level - obstacle_height) then
                        collision_internal <= '1';
                        game_over <= '1';

                    elsif (obstacle_1_x_internal <= dino_x + dino_width) and
                        ((obstacle_1_x_internal + obstacle_width) > dino_x) and
                        (dino_y_internal > ground_level - obstacle_height) then
                        collision_internal <= '1';
                        game_over <= '1';

                    else
                        collision_internal <= '0';
                    end if;



                    if score >= 255 then
                        game_over <= '1';
                    end if;

            
                end if;
            end if;
        end if;
    end process;



    dino_y <= dino_y_internal;
    obstacle_x <= obstacle_x_internal;
    obstacle_1_x <= obstacle_1_x_internal;
    
    game_over_o <= game_over;

    led0_o <= score(0);
    led1_o <= score(1);
    led2_o <= score(2);
    led3_o <= score(3);
    led4_o <= score(4);
    led5_o <= score(5);
    led6_o <= score(6);
    led7_o <= score(7);



    
end architecture rtl;

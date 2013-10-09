private["_onLadder","_itemorignal","_hasfooditem","_rawfood","_cookedfood","_hasoutput","_config","_text","_regen","_dis","_sfx","_Cookedtime","_itemtodrop","_nearByPile","_item","_display"];
disableserialization;

_onLadder =     (getNumber (configFile >> "CfgMovesMaleSdr" >> "States" >> (animationState player) >> "onLadder")) == 1;
if (_onLadder) exitWith {cutText [(localize "str_player_21") , "PLAIN DOWN"]};

if (vehicle player != player) exitWith {cutText ["You may not eat while in a vehicle", "PLAIN DOWN"]};

//Force players to wait 3 mins to eat again
//if (dayz_lastMeal < 180) exitWith {cutText ["You may not eat, you're already full", "PLAIN DOWN"]};

_itemorignal2 = ["FoodPistachio", "FoodNutmix"] +food_with_output + meatcooked;
_itemorignal = "";
{
    if (_x in _itemorignal2) then {
        _itemorignal = _x;
    };
} forEach (magazines player);
if (_itemoriginal == "") then {
    {
        if (_x in meatraw) then {
            _itemorignal = _x;
        };
    } forEach (magazines player);
};
_hasfooditem = _itemorignal in magazines player;

_rawfood = _itemorignal in meatraw;
_cookedfood = _itemorignal in meatcooked;
_hasoutput = _itemorignal in food_with_output;

_config =   configFile >> "CfgMagazines" >> _itemorignal;
_text =     getText (_config >> "displayName");
_regen =    getNumber (_config >> "bloodRegen");

if (!_hasfooditem) exitWith {cutText [format[(localize "str_player_31"),_text,"consume"] , "PLAIN DOWN"]};

player playActionNow "PutDown";
player removeMagazine _itemorignal;
sleep 0.5;

_dis=6;
_sfx = "eat";
[player,_sfx,0,false,_dis] call dayz_zombieSpeak;
[player,_dis,true,(getPosATL player)] spawn player_alertZombies;



if (dayz_lastMeal < 3600) then { 
    if (_itemorignal == "FoodSteakCooked") then {
        //_regen = _regen * (10 - (10 max ((time - _Cookedtime) / 3600)));
    };
};

if (_hasoutput) then{
    // Selecting output
    _itemtodrop = food_output select (food_with_output find _itemorignal);

    sleep 0.1;
    _nearByPile= nearestObjects [(position player), ["groundweaponHolder","groundweaponHolder"],2];
    if (count _nearByPile ==0) then { 
        _item = createVehicle ["groundweaponHolder", position player, [], 0.0, "CAN_COLLIDE"];
    } else {
        _item = _nearByPile select 0;
    };
    _item addMagazineCargoGlobal [_itemtodrop,1];
};

if ( _rawfood and (random 15 < 1)) then {
    if !(_itemorignal in ["FoodzombieRaw"]) then {
    r_player_infected = true;
    player setVariable["USEC_infected",true,true];
    };
};
if ((_itemorignal in ["FoodzombieRaw"]) and (random 15 < 10)) then {
    r_player_infected = true;
    player setVariable["USEC_infected",true,true];
};
if ((_itemorignal in ["FoodzombieCooked"]) and (random 15 < 1)) then {
    r_player_infected = true;
    player setVariable["USEC_infected",true,true];
};

r_player_blood = r_player_blood + _regen;
if (r_player_blood > r_player_bloodTotal) then {
    r_player_blood = r_player_bloodTotal;
};

player setVariable ["messing",[dayz_hunger,dayz_thirst],true];
player setVariable["USEC_BloodQty",r_player_blood,true];
player setVariable["medForceUpdate",true];

//["dayzPlayerSave",[player,[],true]] call callRpcProcedure;
dayzPlayerSave = [player,[],true];
publicVariable "dayzPlayerSave";

dayz_lastMeal = time;
dayz_hunger = 0;



//Ensure Control is visible
_display = uiNamespace getVariable 'DAYZ_GUI_display';
(_display displayCtrl 1301) ctrlShow true;

if (r_player_blood / r_player_bloodTotal >= 0.2) then {
    (_display displayCtrl 1300) ctrlShow true;
};
cutText [format[(localize  "str_player_consumed"),_text], "PLAIN DOWN"];

        player removeAction dayz_hunger2;
        dayz_hunger2 = -1;

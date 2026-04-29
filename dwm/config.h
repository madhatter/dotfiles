/* See LICENSE file for copyright and license details. */

/* Customized config.h */

#include <X11/XF86keysym.h>

/* appearance */
static const unsigned int borderpx	= 2;	/* border pixel of windows */
static const unsigned int gappih	= 6;	/* horiz inner gap between windows */
static const unsigned int gappiv	= 6;	/* vert inner gap between windows */
static const unsigned int gappoh	= 6;	/* horiz outer gap between windows and screen edge */
static const unsigned int gappov	= 6;	/* vert outer gap between windows and screen edge */
static       int smartgaps			= 1;	/* 1 means no outer gap when there is only one window */
static const unsigned int snap		= 32;	/* snap pixel */
static const int showbar			= 1;	/* 0 means no bar */
static const int topbar				= 1;	/* 0 means bottom bar */
static const char *fonts[]			= { "BerkeleyMono Nerd Font Mono:size=13" };
static const char col_bg[]			= "#282828";
static const char col_bg_alt[]		= "#3c3836";
static const char col_fg[]			= "#d5c4a1";
static const char col_fg_dim[]		= "#665c54";
static const char col_accent[]		= "#af87ff";
static const char col_black[]		= "#000000";
static const char col_red[]			= "#ff0000";
static const char col_yellow[]		= "#ffff00";
static const char col_white[]		= "#ffffff";

static const unsigned int baralpha	= 0x99u;
static const unsigned int borderalpha = OPAQUE;

static const char *colors[][3] = {
    /*					fg			bg			border     */
    [SchemeNorm]	= { col_fg,		col_bg,		col_bg_alt },
    [SchemeSel]		= { col_bg,		col_accent,	col_accent },
    [SchemeWarn]	= { col_bg,		col_fg,		col_bg_alt },
    [SchemeUrgent]	= { col_bg,		col_accent,	col_bg_alt },
};

static const unsigned int alphas[][3] = {
    /*					fg			bg			border		*/
    [SchemeNorm]   = { OPAQUE,		baralpha,	borderalpha },
    [SchemeSel]    = { OPAQUE,		baralpha,	borderalpha },
    [SchemeWarn]   = { OPAQUE,		baralpha,	borderalpha },
    [SchemeUrgent] = { OPAQUE,		baralpha,	borderalpha },
};

/* tagging */
//static const char *tags[] = { "", "", "󰆍", "󰈹", "󰭹", "󰓃", "󰓓", "󰍺" };
//static const char *tags[] =  "g", "v", "s", "w", "c", "m", "~", "·" };
static const char *tags[] = { "git", "vim", "sh", "www", "chat", "tune", "play", "misc" };

static const Rule rules[] = {
	/* xprop(1):
	 *	WM_CLASS(STRING) = instance, class
	 *	WM_NAME(STRING) = title
	 */
	/* class			instance    title       tags mask    iscentered   isfloating   monitor */
	{ "jetbrains-idea",	NULL,		NULL,		1 << 1,			0, 				1,		-1 }, // appears on tag 2, floating
	{ "firefox",		NULL,		NULL,		1 << 3,			0, 				0,		-1 }, // appears on tag 4
	{ "elecwhat",		NULL,		NULL,		1 << 4,			1, 				1,		-1 }, // appears on tag 5, floating, centered
	{ "discord",		NULL,		NULL,		1 << 4,			0, 				1,		-1 }, // appears on tag 5, floating
	{ "St",				NULL,		"ncmpcpp",	1 << 5,			1, 				1,		-1 }, // appears on tag 6, floating, centered
	{ "Spotify",		NULL,		NULL,		1 << 5,			0, 				1,		-1 }, // appears on tag 6, floating
	{ "steam",			NULL,		NULL,		1 << 6,			0, 				1,		-1 }, // appears on tag 7, floating
	{ "Gimp",			NULL,		NULL,		1 << 7,			0, 				1,		-1 }, // appears on tag 8, floating
};

/* layout(s) */
static const float mfact		= 0.55; /* factor of master area size [0.05..0.95] */
static const int nmaster		= 1;	/* number of clients in master area */
static const int resizehints	= 0;	/* 1 means respect size hints in tiled resizals */
static const int lockfullscreen	= 1;	/* 1 will force focus on the fullscreen window */

#define FORCE_VSPLIT 1
#include "vanitygaps.c"

static const Layout layouts[] = {
	/* symbol	arrange function */
	{ "[]=",		tile },    /* first entry is default */
	{ "><>",		NULL },    /* no layout function means floating behavior */
	{ "[M]",		monocle },
	{ "TTT",		bstack },
	{ "===",		bstackhoriz },
	{ "[@]",		spiral },
	{ "|M|",		centeredmaster },
};

/* key definitions */
#define MODKEY Mod4Mask
#define TAGKEYS(KEY,TAG) \
	{ MODKEY,						KEY,	view,			{.ui = 1 << TAG} }, \
	{ MODKEY|ControlMask,			KEY,	toggleview,		{.ui = 1 << TAG} }, \
	{ MODKEY|ShiftMask,				KEY,	tag,			{.ui = 1 << TAG} }, \
	{ MODKEY|ControlMask|ShiftMask,	KEY,	toggletag,		{.ui = 1 << TAG} },

/* helper for spawning shell commands in the pre dwm-5.0 fashion */
#define SHCMD(cmd) { .v = (const char*[]){ "/bin/sh", "-c", cmd, NULL } }

/* commands */
static char dmenumon[2] = "0"; /* component of dmenucmd, manipulated in spawn() */
static const char *dmenucmd[]	= { "dmenu_run", "-m", dmenumon, NULL };
static const Arg roficmd		= SHCMD("rofi -show drun");
static const char *termcmd[]	= { "st", NULL };

static const char *lockcmd[]	= { "slock", NULL };
static const char *ncmpcppcmd[] = { "st", "-t", "ncmpcpp", "-e", "ncmpcpp", NULL };

static const char *voldown[]	= { "wpctl", "set-volume", "-l", "1.0", "@DEFAULT_AUDIO_SINK@","5%-",  NULL };
static const char *volup[]		= { "wpctl", "set-volume", "-l", "1.0", "@DEFAULT_AUDIO_SINK@","5%+",  NULL };
static const char *voltoggle[]	= { "wpctl", "set-mute",   "@DEFAULT_AUDIO_SINK@", "toggle", NULL };

static const char *brightup[]	= { "sudo", "light", "-A", "5", NULL};
static const char *brightdown[] = { "sudo", "light", "-U", "5", NULL};

static const char *next[]		= { "mpc", "next", NULL };
static const char *play[]		= { "mpc", "toggle", NULL };
static const char *prev[]		= { "mpc", "prev", NULL };

static const char *snext[]		= { "playerctl", "next", NULL };
static const char *splay[]		= { "playerctl", "play-pause", NULL };
static const char *sprev[]		= { "playerctl", "previous", NULL };

static const Key keys[] = {
	/* modifier					key 		function		argument */
	{ 0,						XF86XK_MonBrightnessDown, spawn, {.v = brightdown} },
	{ 0,						XF86XK_MonBrightnessUp,   spawn, {.v = brightup} },
	{ MODKEY,					XK_r,		spawn,			roficmd },
	{ MODKEY,					XK_Return,	spawn,			{.v = termcmd } },
	{ MODKEY,					XK_a,		spawn,			{.v = lockcmd } },
	{ MODKEY,					XK_n,		spawn,			{.v = ncmpcppcmd } },
	{ MODKEY|ShiftMask,			XK_Up,		spawn,			{.v = volup } },
	{ MODKEY|ShiftMask,			XK_Down,	spawn,			{.v = voldown } },
	{ MODKEY|ShiftMask,			XK_m,		spawn,			{.v = voltoggle } },
	/* Vim-style Volume cont */
	{ MODKEY|ShiftMask,			XK_k,		spawn,			{.v = volup   } },
	{ MODKEY|ShiftMask,			XK_j,		spawn,			{.v = voldown } },
	{ 0,						XF86XK_AudioRaiseVolume, spawn, {.v = volup   } },
	{ 0,						XF86XK_AudioLowerVolume, spawn, {.v = voldown } },
	{ 0,						XF86XK_AudioMute,		 spawn, {.v = voltoggle } },
	{ MODKEY|ShiftMask,			XK_Left,   spawn,			{.v = prev } },
	{ MODKEY|ShiftMask,			XK_Right,  spawn,			{.v = next } },
	{ MODKEY|ShiftMask,			XK_p,      spawn,			{.v = play } },
	{ MODKEY|ControlMask,		XK_Left,   spawn,			{.v = sprev } },
	{ MODKEY|ControlMask,		XK_Right,  spawn,			{.v = snext } },
	{ MODKEY|ControlMask,		XK_p,      spawn,			{.v = splay } },
	{ MODKEY,					XK_b,		togglebar,		{0} },
	{ MODKEY,					XK_j,		focusstack,		{.i = +1 } },
	{ MODKEY,					XK_k,		focusstack,		{.i = -1 } },
	{ MODKEY,					XK_i,		incnmaster,		{.i = +1 } },
	{ MODKEY,					XK_d,		incnmaster,		{.i = -1 } },
	{ MODKEY,					XK_h,		setmfact,		{.f = -0.05} },
	{ MODKEY,					XK_l,		setmfact,		{.f = +0.05} },
	{ MODKEY|ShiftMask,			XK_Return,	zoom,			{0} },
	{ MODKEY,					XK_Tab,		view,			{0} },
	{ MODKEY|ShiftMask,			XK_c,		killclient,		{0} },
	{ MODKEY,					XK_t,		setlayout,		{.v = &layouts[0]} },
	{ MODKEY,					XK_f,		setlayout,		{.v = &layouts[1]} },
	{ MODKEY,					XK_m,		setlayout,		{.v = &layouts[2]} },
	{ MODKEY,					XK_u,		setlayout,		{.v = &layouts[3]} },
	{ MODKEY,					XK_o,		setlayout,		{.v = &layouts[4]} },
	{ MODKEY,					XK_space,	setlayout,		{0} },
	{ MODKEY|ShiftMask,			XK_space,	togglefloating, {0} },
	{ MODKEY,					XK_0,		view,			{.ui = ~0 } },
	{ MODKEY|ShiftMask,			XK_0,		tag,			{.ui = ~0 } },
	{ MODKEY,					XK_comma,	focusmon,		{.i = -1 } },
	{ MODKEY,					XK_period,	focusmon,		{.i = +1 } },
	{ MODKEY|ShiftMask,			XK_comma,	tagmon,			{.i = -1 } },
	{ MODKEY|ShiftMask,			XK_period,	tagmon,			{.i = +1 } },
	/* cfact */
	{ MODKEY|ShiftMask,			XK_h,		setcfact,		{.f = +0.25} },
	{ MODKEY|ShiftMask,			XK_l,		setcfact,		{.f = -0.25} },
	{ MODKEY|ShiftMask,			XK_o,		setcfact,		{.f =  0.00} },
	/* layouts */
	{ MODKEY,					XK_y,		setlayout,		{.v = &layouts[5]} },  // spiral
	{ MODKEY,					XK_e,		setlayout,		{.v = &layouts[6]} },  // centeredmaster
	/* gaps */
	{ MODKEY|Mod1Mask,			XK_u,		incrgaps,		{.i = +2} },
	{ MODKEY|Mod1Mask|ShiftMask,XK_u,		incrgaps, 		{.i = -2} },
	{ MODKEY|Mod1Mask,			XK_0,		togglegaps, 	{0} },
	{ MODKEY|Mod1Mask|ShiftMask,XK_0,		defaultgaps,	{0} },
	{ MODKEY|ShiftMask,			XK_q,		quit,			{0} },

	TAGKEYS(					XK_1,						0)
	TAGKEYS(					XK_2,						1)
	TAGKEYS(					XK_3,						2)
	TAGKEYS(					XK_4,						3)
	TAGKEYS(					XK_5,						4)
	TAGKEYS(					XK_6,						5)
	TAGKEYS(					XK_7,						6)
	TAGKEYS(					XK_8,						7)
};

/* button definitions */
/* click can be ClkTagBar, ClkLtSymbol, ClkStatusText, ClkWinTitle, ClkClientWin, or ClkRootWin */
static const Button buttons[] = {
	/* click				event mask		button			function		argument */
	{ ClkLtSymbol,			0,				Button1,		setlayout,		{0} },
	{ ClkLtSymbol,			0,				Button3,		setlayout,		{.v = &layouts[2]} },
	{ ClkWinTitle,			0,				Button2,		zoom,			{0} },
	{ ClkStatusText,		0,				Button2,		spawn,			{.v = termcmd } },
	{ ClkClientWin,			MODKEY,			Button1,		movemouse,		{0} },
	{ ClkClientWin,			MODKEY,			Button2,		togglefloating,	{0} },
	{ ClkClientWin,			MODKEY,			Button3,		resizemouse,	{0} },
	{ ClkTagBar,			0,				Button1,		view,			{0} },
	{ ClkTagBar,			0,				Button3,		toggleview,		{0} },
	{ ClkTagBar,			MODKEY,			Button1,		tag,			{0} },
	{ ClkTagBar,			MODKEY,			Button3,		toggletag,		{0} },
};

/* vim: set ft=c: */

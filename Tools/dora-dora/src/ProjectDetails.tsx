import React from 'react';
import { Box, Button, Paper, Stack, TextField, Typography } from '@mui/material';
import { createTheme, ThemeProvider } from '@mui/material/styles';
import { Color, theme } from './Theme';
import { Separator } from './Frame';
import ProjectGameDetails, {findReadme, type Language, type ProjectReadme} from './ProjectGameDetails';
import ProjectCoverCrop from './ProjectCoverCrop';
import ImageOutlined from '@mui/icons-material/ImageOutlined';
import AddPhotoAlternateOutlined from '@mui/icons-material/AddPhotoAlternateOutlined';
import Info from './Info';
import './ProjectDetails.css';
import { useTranslation } from 'react-i18next';
import * as Service from './Service';
import {findProjectCover, projectDescriptions, readProjectCard, ProjectCardWriter} from './ProjectCard';

const detailsTheme = createTheme(theme, {
	palette: {action: {active:Color.Primary}},
	components: {
		MuiToggleButton: {styleOverrides: {root: {
			color:Color.Primary, borderColor:Color.LineStrong,
			'&:hover': {color:Color.TextPrimary, backgroundColor:Color.SurfaceHover},
			'&.Mui-selected, &.Mui-selected:hover': {color:Color.Theme, backgroundColor:Color.ThemeMuted},
		}}},
		MuiInputBase: {styleOverrides: {input: {'&::placeholder': {color:Color.DisabledText, opacity:1}}}},
		MuiFormHelperText: {styleOverrides: {root: {color:Color.Primary, '&.Mui-disabled': {color:Color.DisabledText}}}},
		MuiButtonBase: {styleOverrides: {root: {'&.Mui-focusVisible': {outline:`2px solid ${Color.Theme}`, outlineOffset:-2}}}},
		MuiButton: {styleOverrides: {
			containedPrimary: {color:Color.BackgroundDark, backgroundColor:Color.Theme, '&:hover': {backgroundColor:Color.Theme}},
			textPrimary: {'&:hover': {backgroundColor:Color.SurfaceHover, color:Color.TextPrimary}},
		}},
	},
});

const emptyReadme: ProjectReadme = {path:'', text:'', exists:false};
const sectionStyle = {
	display:'grid', gap:2, minWidth:0, p:2.5, bgcolor:Color.SurfaceRaised, borderColor:Color.Line,
	'& h3':{display:'flex', alignItems:'center', gap:1, fontWeight:600},
	'& h3 svg':{color:Color.Theme, fontSize:18},
	'& summary':{cursor:'pointer', color:Color.Primary},
};

interface ProjectDetailsProps {
	fileUrl: (path:string) => string;
	project: string; repository: string; active: boolean; onCardSaved: () => void;
	onOpenFile?: (file: string) => void; onGenerateReadme: (root: string, lang:Language) => void;
}
export default function ProjectDetails(props: ProjectDetailsProps) {
	return <ThemeProvider theme={detailsTheme}><DetailsForm {...props} /></ThemeProvider>;
}

function DetailsForm({project, repository, active, fileUrl, onCardSaved, onOpenFile, onGenerateReadme}: ProjectDetailsProps) {
	const {t, i18n} = useTranslation();
	const chinese = i18n.language.startsWith('zh');
	const label = React.useCallback((zh:string,en:string) => chinese ? zh : en,[chinese]);
	const [descriptions, setDescriptions] = React.useState({zh:'', en:''});
	const [language, setLanguage] = React.useState<Language>(i18n.language.startsWith('zh') ? 'zh' : 'en');
	const [readmes, setReadmes] = React.useState({zh:emptyReadme, en:emptyReadme});
	const [readingReadme, setReadingReadme] = React.useState(false);
	const [categories, setCategories] = React.useState('');
	const [saveState, setSaveState] = React.useState<'idle'|'pending'|'saved'|'error'|'conflict'>('idle');
	const writer = React.useRef<ProjectCardWriter | undefined>(undefined);
	const savedCallback = React.useRef(onCardSaved);
	savedCallback.current = onCardSaved;
	const [reload, setReload] = React.useState(0);
	React.useEffect(() => () => {void writer.current?.flush();}, []);
	const [zh, setZh] = React.useState('');
	const [en, setEn] = React.useState('');
	const [cropSource, setCropSource] = React.useState<File | string>();
	const [sourceFile, setSourceFile] = React.useState<File>();
	const [coverPath, setCoverPath] = React.useState('');
	const [cover, setCover] = React.useState<File>();
	const [original, setOriginal] = React.useState<string>();
	const [cardRoot, setCardRoot] = React.useState('');
	const [notice, setNotice] = React.useState('');
	const projectImage = coverPath && fileUrl(Info.path.join(cardRoot, coverPath));
	const [projectCover, setProjectCover] = React.useState<File>();
	const [coverRevision, setCoverRevision] = React.useState(0);
	const [coverError, setCoverError] = React.useState(false);
	const [image, setImage] = React.useState('');
	const currentCover = cover ?? projectCover;
	React.useEffect(() => {
		const controller = new AbortController();
		setProjectCover(undefined);
		setCoverError(false);
		if (projectImage) {
			void (async () => {
				const response = await fetch(projectImage, {cache:'no-store', signal:controller.signal});
				if (!response.ok) throw new Error('cover');
				const blob = await response.blob();
				if (!controller.signal.aborted) setProjectCover(new File([blob], Info.path.basename(coverPath), {type:blob.type}));
			})().catch(() => {if (!controller.signal.aborted) setCoverError(true);});
		}
		return () => controller.abort();
	}, [projectImage, coverPath, coverRevision]);
	React.useEffect(() => {
		if (!currentCover) {setImage(''); return;}
		const url = URL.createObjectURL(currentCover);
		setImage(url);
		setCoverError(false);
		return () => URL.revokeObjectURL(url);
	}, [currentCover]);
	React.useEffect(() => {
		if (!active) {void writer.current?.flush(); return;}
		if (writer.current?.unsaved) return;
		setOriginal(undefined);
		let current = true;
		async function load() {
			const entry = await Service.projectRoot({path: project, isDir: true});
			if (!current) return;
			const godot = (await Service.exist({file: Info.path.join(project, 'project.godot')})).success;
			if (!current) return;
			const root = godot ? project : entry.projectRoot || project;
			setCardRoot(root);
			const [card, path] = await Promise.all([readProjectCard(root), findProjectCover(root)]);
			if (!current) return;
			const next = new ProjectCardWriter(root,card.content,(state, savedCover) => {
				if (writer.current !== next) return;
				setSaveState(state);
				if (savedCover) {
					setCoverPath('.dora/banner.jpg');
					setCoverRevision(n => n + 1);
				}
				if (state === 'saved') savedCallback.current();
			});
			writer.current = next;
			setSaveState('idle');
			setNotice('');
			setOriginal(card.content);
			setCategories(Array.isArray(card.metadata.categories) ? card.metadata.categories.join(', ') : '');
			setCover(undefined);
			setSourceFile(undefined);
			setDescriptions(projectDescriptions(card.metadata));
			setZh(typeof card.metadata.title?.zh === 'string' ? card.metadata.title.zh : '');
			setEn(typeof card.metadata.title?.en === 'string' ? card.metadata.title.en : '');
			setCoverPath(path);
		}
		void load().catch(() => { if (current) setNotice('agent.projectCardError'); });
		return () => { current = false; };
	}, [project, active, reload]);
	React.useEffect(() => {
		if (!active || !cardRoot) return;
		let current = true;
		setReadingReadme(true);
		async function load() {
			const [zh, en] = await Promise.all([findReadme(cardRoot, repository, 'zh'), findReadme(cardRoot, repository, 'en')]);
			if (current) setReadmes({zh,en});
		}
		void load().catch(() => { if (current) setNotice('agent.projectReadmeError'); })
			.finally(() => { if (current) setReadingReadme(false); });
		return () => { current = false; };
	}, [active, cardRoot, repository]);
	return <Box className="project-details-studio" sx={{height:'100%', overflow:'auto', containerType:'inline-size', color:'text.primary', bgcolor:'background.default'}}>
		<Stack spacing={2.5} className="project-details-sheet">
			<Stack direction="row" alignItems="center" justifyContent="space-between" gap={2} flexWrap="wrap">
				<Typography component="h2" variant="h5">{label('Dora 项目资料','Dora project details')}</Typography>
			</Stack>
			<Separator />
			<div className="project-details-columns" onBlur={() => void writer.current?.flush()}>
				<ProjectGameDetails fileUrl={fileUrl} language={language} onLanguage={setLanguage} titles={{zh,en}} summaries={descriptions}
					onTitle={(lang, value) => {(lang === 'zh' ? setZh : setEn)(value); writer.current?.edit({title:{[lang]:value}});}}
					onSummary={(lang, value) => {setDescriptions(prev => ({...prev, [lang]:value})); writer.current?.edit({description:{[lang]:value}});}}
					readmes={readmes} onReadme={(lang, value) => setReadmes(prev => ({...prev, [lang]:value}))}
					reading={readingReadme} disabled={original === undefined} label={label}
					onGenerate={lang => onGenerateReadme(cardRoot, lang)}
					onSettings={original !== undefined && (original || saveState === 'saved') && onOpenFile ? () => onOpenFile(Info.path.join(cardRoot, '.dora', 'repo.json')) : undefined} />
				<Stack spacing={2} sx={{minWidth:0}}>
					<Paper component="section" variant="outlined" sx={sectionStyle}>
						<Typography component="h3" variant="subtitle1"><ImageOutlined />{label('作品封面','Cover')}</Typography>
						<Button component="label" variant="outlined" disabled={original === undefined}
							aria-label={t('agent.projectCover')} sx={{aspectRatio:'16/9', overflow:'hidden', flexDirection:'column', gap:1}}>
							{image && !coverError ? <Box component="img" src={image} onError={() => setCoverError(true)} alt={label('当前作品封面','Game cover')} sx={{position:'absolute', inset:0, width:'100%', height:'100%', objectFit:'cover'}} /> :
								<><AddPhotoAlternateOutlined />{label('选择封面图片','Choose cover image')}</>}
							<input hidden type="file" accept="image/jpeg,image/png" onChange={event => {
								const file = event.target.files?.[0]; if (file) setCropSource(file); event.target.value='';
							}} />
						</Button>
						<Stack direction="row" alignItems="center" justifyContent="space-between" gap={1}>
						<Typography variant="caption" color="text.secondary">JPG / PNG · 16:9
							{coverError ? label(' · 封面读取失败，请重新选图。',' · Could not load the cover. Choose another image.') : !image && label(' · 裁剪后自动保存为启动器封面。',' · Crop to save as the launcher cover.')}</Typography>
						{image && !coverError && <Button size="small" disabled={original === undefined} onClick={() => setCropSource(sourceFile || currentCover)}>{label('裁剪封面','Crop cover')}</Button>}
						</Stack>
					</Paper>
					<Paper component="section" variant="outlined" sx={sectionStyle}>
						<TextField size="small" label={label('启动器分类','Launcher categories')} value={categories} disabled={original === undefined}
							helperText={label('多个分类用逗号分隔。Tool 会将项目列入工具。','Separate categories with commas. Tool lists the project under Tools.')}
							onChange={event => {
								const value = event.target.value;
								setCategories(value);
								writer.current?.edit({categories:value.split(/[,，]/).map(item=>item.trim()).filter(Boolean)});
							}} />
					</Paper>
				</Stack>
			</div>
			<Stack direction="row" alignItems="center" gap={1} role="status">
				<Typography variant="body2" color={['error','conflict'].includes(saveState) ? 'error' : 'text.secondary'}>
					{saveState === 'pending' ? label('正在保存到项目…','Saving to project…') :
						saveState === 'saved' ? label('已自动保存到项目','Changes saved to project') :
						saveState === 'error' ? label('保存失败，请重试。','Could not save changes. Please retry.') :
						saveState === 'conflict' ? label('同一字段已在工程中更改。可重新载入磁盘版本。','The same field changed on disk. Reload the project copy.') :
						label('标题、简介、分类和封面会自动保存到 .dora。','Title, summary, categories and cover save automatically to .dora.')}
				</Typography>
				{saveState === 'error' && <Button onClick={()=>void writer.current?.flush()}>{label('重试保存','Retry save')}</Button>}
				{saveState === 'conflict' && <Button onClick={()=>{
					writer.current = undefined;setOriginal(undefined);setReload(n=>n+1);
				}}>{label('放弃本地修改并重新载入','Discard local edits and reload')}</Button>}
			</Stack>
			{notice && <Stack direction="row" alignItems="center" spacing={1}>
				<Typography role="alert" variant="body2">{t(notice)}</Typography>
				{original === undefined && <Button onClick={()=>setReload(n=>n+1)}>{label('重新读取项目','Reload project')}</Button>}
			</Stack>}
		</Stack>
		{cropSource && <ProjectCoverCrop source={cropSource} label={label} onClose={() => setCropSource(undefined)}
			onConfirm={file => {setSourceFile(typeof cropSource === 'string' ? undefined : cropSource); setCover(file); writer.current?.edit({cover:file}); setCropSource(undefined);}} />}
	</Box>;
}
